//
//  CoinGeckoService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

protocol CoinGeckoServiceProtocol {
    func fetchBitcoinPrice() async throws -> BitcoinPrice
    func fetchExchanges() async throws -> ExchangeData
    func fetchHistoricalPrice(for period: HistoricalPeriod, currentPrice: Double) async throws -> HistoricalPriceData
}

final class CoinGeckoService: CoinGeckoServiceProtocol {
    static let shared = CoinGeckoService()
    
    private let apiService: APIService
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Bitcoin Price
    func fetchBitcoinPrice() async throws -> BitcoinPrice {
        let response: BitcoinDetailResponse = try await apiService.fetchWithCache(
            from: AppConstants.API.bitcoinDetail,
            cacheDuration: AppConstants.CacheDuration.price
        )
        
        return mapToBitcoinPrice(response)
    }
    
    // MARK: - Fetch Simple Price (Lighter call)
    func fetchSimplePrice() async throws -> BitcoinPriceData {
        let response: CoinGeckoPriceResponse = try await apiService.fetch(
            from: AppConstants.API.bitcoinPrice
        )
        
        return response.bitcoin
    }
    
    // MARK: - Fetch Exchanges
    func fetchExchanges() async throws -> ExchangeData {
        let response: [ExchangeResponse] = try await apiService.fetchWithCache(
            from: AppConstants.API.exchanges,
            cacheDuration: AppConstants.CacheDuration.positions
        )
        
        return mapToExchangeData(response)
    }
    
    // MARK: - Mapping Functions
    private func mapToBitcoinPrice(_ response: BitcoinDetailResponse) -> BitcoinPrice {
        let marketData = response.marketData
        
        return BitcoinPrice(
            price: marketData.currentPrice["usd"] ?? 0,
            priceChange24h: marketData.priceChange24h,
            priceChangePercentage24h: marketData.priceChangePercentage24h,
            marketCap: marketData.marketCap["usd"] ?? 0,
            volume24h: marketData.totalVolume["usd"] ?? 0,
            high24h: marketData.high24h["usd"] ?? 0,
            low24h: marketData.low24h["usd"] ?? 0,
            ath: marketData.ath["usd"] ?? 0,
            athChangePercentage: marketData.athChangePercentage["usd"] ?? 0,
            circulatingSupply: marketData.circulatingSupply,
            lastUpdated: Date()
        )
    }
    
    private func mapToExchangeData(_ response: [ExchangeResponse]) -> ExchangeData {
        let exchanges = response.compactMap { exchange -> Exchange? in
            guard let volume = exchange.tradeVolume24hBtc,
                  let normalizedVolume = exchange.tradeVolume24hBtcNormalized else {
                return nil
            }
            
            return Exchange(
                id: exchange.id,
                name: exchange.name,
                country: exchange.country ?? "Unknown",
                trustScore: exchange.trustScore ?? 0,
                volume24hBTC: volume,
                volumeNormalized: normalizedVolume
            )
        }
        
        let totalVolume = exchanges.reduce(0) { $0 + $1.volume24hBTC }
        
        return ExchangeData(
            exchanges: exchanges,
            totalVolume: totalVolume,
            volumeChange24h: 0, // Would need historical data for this
            lastUpdated: Date()
        )
    }
    
    // MARK: - Fetch Historical Price
    func fetchHistoricalPrice(for period: HistoricalPeriod, currentPrice: Double) async throws -> HistoricalPriceData {
        let dateString = period.dateString
        let url = AppConstants.API.bitcoinHistory(date: dateString)
        
        let response: CoinGeckoHistoricalResponse = try await apiService.fetchWithCache(
            from: url,
            cacheDuration: 86400 // Cache for 24 hours - historical data doesn't change
        )
        
        guard let marketData = response.marketData,
              let price = marketData.currentPrice["usd"] else {
            throw APIError.noData
        }
        
        return HistoricalPriceData(
            period: period,
            date: period.date,
            price: price,
            currentPrice: currentPrice
        )
    }
    
    // MARK: - Fetch All Historical Prices
    func fetchAllHistoricalPrices(currentPrice: Double) async -> HistoricalPriceCollection {
        var collection = HistoricalPriceCollection()
        collection.isLoading = true
        
        // Fetch sequentially with delays to avoid rate limiting
        for period in HistoricalPeriod.allCases {
            do {
                // Add delay between requests to avoid rate limiting (except first)
                if period != .oneMonth {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                }
                
                let data = try await fetchHistoricalPrice(for: period, currentPrice: currentPrice)
                collection.prices[period] = data
            } catch {
                print("Failed to fetch \(period.displayName) price: \(error)")
                // Use fallback data for this period
                if let fallback = Self.fallbackHistoricalPrice(for: period, currentPrice: currentPrice) {
                    collection.prices[period] = fallback
                }
            }
        }
        
        collection.isLoading = false
        collection.lastUpdated = Date()
        return collection
    }
    
    // MARK: - Fallback Historical Prices
    /// Returns estimated historical prices when API fails (based on known Bitcoin history)
    private static func fallbackHistoricalPrice(for period: HistoricalPeriod, currentPrice: Double) -> HistoricalPriceData? {
        // Estimated prices based on Bitcoin historical data
        // These are approximations and will be replaced by real API data when available
        let estimatedPrice: Double
        
        switch period {
        case .oneMonth:
            // 1 month ago - estimate ~5% variance
            estimatedPrice = currentPrice * 0.95
        case .oneYear:
            // 1 year ago (Jan 2025) - Bitcoin was around $42,000-45,000
            estimatedPrice = 43_000
        case .fourYears:
            // 4 years ago (Jan 2022) - Bitcoin was around $35,000-42,000
            estimatedPrice = 38_000
        case .tenYears:
            // 10 years ago (Jan 2016) - Bitcoin was around $400-450
            estimatedPrice = 430
        }
        
        return HistoricalPriceData(
            period: period,
            date: period.date,
            price: estimatedPrice,
            currentPrice: currentPrice,
            isEstimated: true
        )
    }
}
