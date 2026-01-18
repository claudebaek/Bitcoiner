//
//  MarketDataService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import Foundation

// MARK: - Market Asset Type
enum MarketAsset: String, CaseIterable {
    case gold = "GC=F"           // Gold Futures
    case nasdaq = "^IXIC"        // NASDAQ Composite
    case kospi = "^KS11"         // KOSPI
    case dollarIndex = "DX-Y.NYB" // US Dollar Index (DXY)
    case realEstate = "VNQ"      // Vanguard Real Estate ETF (proxy for real estate)
    
    var displayName: String {
        switch self {
        case .gold: return "Gold"
        case .nasdaq: return "NASDAQ"
        case .kospi: return "KOSPI"
        case .dollarIndex: return "Dollar Index"
        case .realEstate: return "Real Estate"
        }
    }
    
    var yahooSymbol: String {
        rawValue
    }
}

// MARK: - Market Price Data
struct MarketPriceData: Identifiable {
    let id = UUID()
    let asset: MarketAsset
    let currentPrice: Double
    let previousClose: Double
    let historicalPrices: [MarketHistoricalPrice]
    let lastUpdated: Date
    
    var priceChange: Double {
        currentPrice - previousClose
    }
    
    var priceChangePercentage: Double {
        guard previousClose > 0 else { return 0 }
        return ((currentPrice - previousClose) / previousClose) * 100
    }
    
    /// Get price at a specific period ago
    func price(for period: ComparisonPeriod) -> Double? {
        historicalPrices.first { $0.period == period }?.price
    }
    
    /// Calculate return for a period
    func returnPercentage(for period: ComparisonPeriod) -> Double? {
        guard let historicalPrice = price(for: period), historicalPrice > 0 else { return nil }
        return ((currentPrice - historicalPrice) / historicalPrice) * 100
    }
}

// MARK: - Market Historical Price
struct MarketHistoricalPrice: Identifiable {
    let id = UUID()
    let period: ComparisonPeriod
    let price: Double
    let date: Date
}

// MARK: - Yahoo Finance Response Models
struct YahooChartResponse: Codable {
    let chart: YahooChartResult
}

struct YahooChartResult: Codable {
    let result: [YahooChartData]?
    let error: YahooError?
}

struct YahooChartData: Codable {
    let meta: YahooMeta
    let timestamp: [Int]?
    let indicators: YahooIndicators
}

struct YahooMeta: Codable {
    let regularMarketPrice: Double?
    let previousClose: Double?
    let currency: String?
    let symbol: String
}

struct YahooIndicators: Codable {
    let quote: [YahooQuote]?
}

struct YahooQuote: Codable {
    let close: [Double?]?
    let open: [Double?]?
    let high: [Double?]?
    let low: [Double?]?
}

struct YahooError: Codable {
    let code: String?
    let description: String?
}

// MARK: - All Market Data Collection
struct MarketDataCollection {
    var gold: MarketPriceData?
    var nasdaq: MarketPriceData?
    var kospi: MarketPriceData?
    var dollarIndex: MarketPriceData?
    var realEstate: MarketPriceData?
    var isLoading: Bool = false
    var error: String?
    var lastUpdated: Date?
    
    static var placeholder: MarketDataCollection {
        MarketDataCollection()
    }
    
    var isComplete: Bool {
        gold != nil && nasdaq != nil && kospi != nil && dollarIndex != nil && realEstate != nil
    }
}

// MARK: - Market Data Service
final class MarketDataService {
    static let shared = MarketDataService()
    
    private let apiService: APIService
    private let baseURL = "https://query1.finance.yahoo.com/v8/finance/chart"
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Current Price with History
    func fetchMarketData(for asset: MarketAsset) async throws -> MarketPriceData {
        // Fetch 1 year data to get all periods (1M uses the same data)
        let url = buildURL(symbol: asset.yahooSymbol, range: "1y", interval: "1d")
        
        let response: YahooChartResponse = try await apiService.fetch(from: url)
        
        guard let chartData = response.chart.result?.first else {
            if let error = response.chart.error {
                throw MarketDataError.apiError(error.description ?? "Unknown error")
            }
            throw MarketDataError.noData
        }
        
        let currentPrice = chartData.meta.regularMarketPrice ?? 0
        let previousClose = chartData.meta.previousClose ?? currentPrice
        
        // Extract historical prices for our comparison periods
        let historicalPrices = extractHistoricalPrices(
            from: chartData,
            asset: asset
        )
        
        return MarketPriceData(
            asset: asset,
            currentPrice: currentPrice,
            previousClose: previousClose,
            historicalPrices: historicalPrices,
            lastUpdated: Date()
        )
    }
    
    // MARK: - Fetch Long-term Historical Data (for 4Y and 10Y)
    func fetchLongTermData(for asset: MarketAsset) async throws -> [MarketHistoricalPrice] {
        // Yahoo Finance max range for free API
        let url = buildURL(symbol: asset.yahooSymbol, range: "max", interval: "1mo")
        
        let response: YahooChartResponse = try await apiService.fetch(from: url)
        
        guard let chartData = response.chart.result?.first,
              let timestamps = chartData.timestamp,
              let quotes = chartData.indicators.quote?.first,
              let closes = quotes.close else {
            return []
        }
        
        var results: [MarketHistoricalPrice] = []
        let now = Date()
        
        // Find prices for 4Y and 10Y ago
        for period in [ComparisonPeriod.fourYears, ComparisonPeriod.tenYears] {
            let targetDate = period.startDate
            
            // Find closest timestamp to target date
            if let (index, _) = findClosestTimestamp(timestamps: timestamps, to: targetDate) {
                if index < closes.count, let price = closes[index] {
                    results.append(MarketHistoricalPrice(
                        period: period,
                        price: price,
                        date: targetDate
                    ))
                }
            }
        }
        
        return results
    }
    
    // MARK: - Fetch All Market Data
    func fetchAllMarketData() async -> MarketDataCollection {
        var collection = MarketDataCollection()
        collection.isLoading = true
        
        // Fetch in parallel with error handling for each
        await withTaskGroup(of: (MarketAsset, MarketPriceData?).self) { group in
            for asset in [MarketAsset.gold, .nasdaq, .kospi, .dollarIndex, .realEstate] {
                group.addTask {
                    do {
                        // Add small delay to avoid rate limiting
                        if asset != .gold {
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                        }
                        let data = try await self.fetchMarketData(for: asset)
                        return (asset, data)
                    } catch {
                        print("Failed to fetch \(asset.displayName): \(error)")
                        return (asset, nil)
                    }
                }
            }
            
            for await (asset, data) in group {
                switch asset {
                case .gold: collection.gold = data
                case .nasdaq: collection.nasdaq = data
                case .kospi: collection.kospi = data
                case .dollarIndex: collection.dollarIndex = data
                case .realEstate: collection.realEstate = data
                }
            }
        }
        
        // Fetch long-term data for assets that need it
        await fetchLongTermDataForCollection(&collection)
        
        collection.isLoading = false
        collection.lastUpdated = Date()
        return collection
    }
    
    // MARK: - Private Helpers
    private func buildURL(symbol: String, range: String, interval: String) -> String {
        let encodedSymbol = symbol.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? symbol
        return "\(baseURL)/\(encodedSymbol)?range=\(range)&interval=\(interval)&includePrePost=false"
    }
    
    private func extractHistoricalPrices(from chartData: YahooChartData, asset: MarketAsset) -> [MarketHistoricalPrice] {
        guard let timestamps = chartData.timestamp,
              let quotes = chartData.indicators.quote?.first,
              let closes = quotes.close else {
            return []
        }
        
        var results: [MarketHistoricalPrice] = []
        
        // Extract 1M and 1Y prices from the 1Y data
        for period in [ComparisonPeriod.oneMonth, ComparisonPeriod.oneYear] {
            let targetDate = period.startDate
            
            if let (index, _) = findClosestTimestamp(timestamps: timestamps, to: targetDate) {
                if index < closes.count, let price = closes[index] {
                    results.append(MarketHistoricalPrice(
                        period: period,
                        price: price,
                        date: targetDate
                    ))
                }
            }
        }
        
        return results
    }
    
    private func findClosestTimestamp(timestamps: [Int], to date: Date) -> (index: Int, timestamp: Int)? {
        let targetTimestamp = Int(date.timeIntervalSince1970)
        
        var closestIndex = 0
        var closestDiff = Int.max
        
        for (index, ts) in timestamps.enumerated() {
            let diff = abs(ts - targetTimestamp)
            if diff < closestDiff {
                closestDiff = diff
                closestIndex = index
            }
        }
        
        guard closestIndex < timestamps.count else { return nil }
        return (closestIndex, timestamps[closestIndex])
    }
    
    private func fetchLongTermDataForCollection(_ collection: inout MarketDataCollection) async {
        // Fetch 4Y and 10Y data for each asset
        for asset in [MarketAsset.gold, .nasdaq, .kospi, .dollarIndex, .realEstate] {
            do {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s delay
                let longTermPrices = try await fetchLongTermData(for: asset)
                
                // Merge with existing data
                switch asset {
                case .gold:
                    if let existing = collection.gold {
                        collection.gold = mergeHistoricalPrices(existing: existing, newPrices: longTermPrices)
                    }
                case .nasdaq:
                    if let existing = collection.nasdaq {
                        collection.nasdaq = mergeHistoricalPrices(existing: existing, newPrices: longTermPrices)
                    }
                case .kospi:
                    if let existing = collection.kospi {
                        collection.kospi = mergeHistoricalPrices(existing: existing, newPrices: longTermPrices)
                    }
                case .dollarIndex:
                    if let existing = collection.dollarIndex {
                        collection.dollarIndex = mergeHistoricalPrices(existing: existing, newPrices: longTermPrices)
                    }
                case .realEstate:
                    if let existing = collection.realEstate {
                        collection.realEstate = mergeHistoricalPrices(existing: existing, newPrices: longTermPrices)
                    }
                }
            } catch {
                print("Failed to fetch long-term data for \(asset.displayName): \(error)")
            }
        }
    }
    
    private func mergeHistoricalPrices(existing: MarketPriceData, newPrices: [MarketHistoricalPrice]) -> MarketPriceData {
        var allPrices = existing.historicalPrices
        allPrices.append(contentsOf: newPrices)
        return MarketPriceData(
            asset: existing.asset,
            currentPrice: existing.currentPrice,
            previousClose: existing.previousClose,
            historicalPrices: allPrices,
            lastUpdated: existing.lastUpdated
        )
    }
}

// MARK: - Market Data Error
enum MarketDataError: LocalizedError {
    case noData
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No market data available"
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
