//
//  FearGreedService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

protocol FearGreedServiceProtocol {
    func fetchCurrentIndex() async throws -> FearGreedIndex
    func fetchHistoricalData(days: Int) async throws -> [FearGreedHistoryPoint]
}

final class FearGreedService: FearGreedServiceProtocol {
    static let shared = FearGreedService()
    
    private let apiService: APIService
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Current Fear & Greed Index
    func fetchCurrentIndex() async throws -> FearGreedIndex {
        let response: FearGreedResponse = try await apiService.fetchWithCache(
            from: AppConstants.API.fearGreedCurrent,
            cacheDuration: AppConstants.CacheDuration.fearGreed
        )
        
        guard let currentData = response.data.first else {
            throw APIError.noData
        }
        
        // Also fetch historical data
        let historicalData = try await fetchHistoricalData(days: 7)
        
        return mapToFearGreedIndex(currentData, historicalData: historicalData)
    }
    
    // MARK: - Fetch Historical Data
    func fetchHistoricalData(days: Int) async throws -> [FearGreedHistoryPoint] {
        let urlString = "\(AppConstants.API.fearGreedBase)/?limit=\(days)"
        
        let response: FearGreedResponse = try await apiService.fetch(from: urlString)
        
        return response.data.compactMap { data -> FearGreedHistoryPoint? in
            guard let value = Int(data.value),
                  let timestamp = Double(data.timestamp) else {
                return nil
            }
            
            return FearGreedHistoryPoint(
                value: value,
                date: Date(timeIntervalSince1970: timestamp)
            )
        }
    }
    
    // MARK: - Mapping
    private func mapToFearGreedIndex(_ data: FearGreedData, historicalData: [FearGreedHistoryPoint]) -> FearGreedIndex {
        let value = Int(data.value) ?? 50
        let timestamp = Double(data.timestamp) ?? Date().timeIntervalSince1970
        
        return FearGreedIndex(
            value: value,
            classification: FearGreedClassification.from(string: data.valueClassification),
            timestamp: Date(timeIntervalSince1970: timestamp),
            historicalData: historicalData
        )
    }
}
