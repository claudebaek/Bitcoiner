//
//  NewsService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/22/26.
//

import Foundation

final class NewsService {
    static let shared = NewsService()
    
    private let apiService = APIService.shared
    private let baseURL = "https://min-api.cryptocompare.com/data/v2/news/"
    
    private init() {}
    
    /// Fetch latest Bitcoin news
    func fetchNews(limit: Int = 10) async throws -> [BitcoinNews] {
        let urlString = "\(baseURL)?lang=EN&categories=BTC&excludeCategories=Sponsored&lTs=0"
        
        let response: CryptoCompareNewsResponse = try await apiService.fetchWithCache(
            from: urlString,
            cacheDuration: 300 // 5 minutes cache
        )
        
        return Array(response.Data.prefix(limit).map { $0.toNews() })
    }
}
