//
//  APIService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case rateLimited
    case serverError(Int)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .rateLimited:
            return "Rate limited. Please try again later."
        case .serverError(let code):
            return "Server error: \(code)"
        case .noData:
            return "No data received"
        }
    }
}

// MARK: - API Service Protocol
protocol APIServiceProtocol {
    func fetch<T: Decodable>(from urlString: String) async throws -> T
}

// MARK: - API Service
final class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private var cache: [String: CacheEntry] = [:]
    private let cacheQueue = DispatchQueue(label: "com.bitcoiner.cache")
    
    private struct CacheEntry {
        let data: Data
        let timestamp: Date
    }
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    return decoded
                } catch {
                    throw APIError.decodingFailed(error)
                }
            case 429:
                throw APIError.rateLimited
            case 400...499:
                throw APIError.invalidResponse
            case 500...599:
                throw APIError.serverError(httpResponse.statusCode)
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.requestFailed(error)
        }
    }
    
    // MARK: - Cached Fetch
    func fetchWithCache<T: Decodable>(from urlString: String, cacheDuration: TimeInterval) async throws -> T {
        // Check cache first
        if let cached = getCachedData(for: urlString, maxAge: cacheDuration) {
            do {
                return try decoder.decode(T.self, from: cached)
            } catch {
                // Cache invalid, continue to fetch
            }
        }
        
        // Fetch fresh data
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        // Cache the response
        setCachedData(data, for: urlString)
        
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Cache Helpers
    private func getCachedData(for key: String, maxAge: TimeInterval) -> Data? {
        cacheQueue.sync {
            guard let entry = cache[key] else { return nil }
            guard Date().timeIntervalSince(entry.timestamp) < maxAge else {
                cache.removeValue(forKey: key)
                return nil
            }
            return entry.data
        }
    }
    
    private func setCachedData(_ data: Data, for key: String) {
        cacheQueue.async { [weak self] in
            self?.cache[key] = CacheEntry(data: data, timestamp: Date())
        }
    }
    
    func clearCache() {
        cacheQueue.async { [weak self] in
            self?.cache.removeAll()
        }
    }
}
