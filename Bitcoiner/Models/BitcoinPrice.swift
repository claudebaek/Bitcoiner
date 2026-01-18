//
//  BitcoinPrice.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

// MARK: - CoinGecko Simple Price Response
struct CoinGeckoPriceResponse: Codable {
    let bitcoin: BitcoinPriceData
}

struct BitcoinPriceData: Codable {
    let usd: Double
    let usdMarketCap: Double
    let usd24hVol: Double
    let usd24hChange: Double
    
    enum CodingKeys: String, CodingKey {
        case usd
        case usdMarketCap = "usd_market_cap"
        case usd24hVol = "usd_24h_vol"
        case usd24hChange = "usd_24h_change"
    }
}

// MARK: - CoinGecko Detailed Bitcoin Response
struct BitcoinDetailResponse: Codable {
    let id: String
    let symbol: String
    let name: String
    let marketData: MarketData
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case marketData = "market_data"
    }
}

struct MarketData: Codable {
    let currentPrice: [String: Double]
    let marketCap: [String: Double]
    let totalVolume: [String: Double]
    let high24h: [String: Double]
    let low24h: [String: Double]
    let priceChange24h: Double
    let priceChangePercentage24h: Double
    let priceChangePercentage7d: Double
    let priceChangePercentage30d: Double
    let ath: [String: Double]
    let athChangePercentage: [String: Double]
    let athDate: [String: String]
    let circulatingSupply: Double
    let totalSupply: Double?
    let maxSupply: Double?
    
    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChange24h = "price_change_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case priceChangePercentage7d = "price_change_percentage_7d"
        case priceChangePercentage30d = "price_change_percentage_30d"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
    }
}

// MARK: - App Model
struct BitcoinPrice: Identifiable {
    let id = UUID()
    let price: Double
    let priceChange24h: Double
    let priceChangePercentage24h: Double
    let marketCap: Double
    let volume24h: Double
    let high24h: Double
    let low24h: Double
    let ath: Double
    let athChangePercentage: Double
    let circulatingSupply: Double
    let lastUpdated: Date
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? "$0.00"
    }
    
    var formattedMarketCap: String {
        formatLargeNumber(marketCap)
    }
    
    var formattedVolume: String {
        formatLargeNumber(volume24h)
    }
    
    var formattedATH: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: ath)) ?? "$0"
    }
    
    var isPriceUp: Bool {
        priceChangePercentage24h >= 0
    }
    
    private func formatLargeNumber(_ number: Double) -> String {
        let trillion = 1_000_000_000_000.0
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        
        if number >= trillion {
            return String(format: "$%.2fT", number / trillion)
        } else if number >= billion {
            return String(format: "$%.2fB", number / billion)
        } else if number >= million {
            return String(format: "$%.2fM", number / million)
        } else {
            return String(format: "$%.2f", number)
        }
    }
    
    static var placeholder: BitcoinPrice {
        BitcoinPrice(
            price: 0,
            priceChange24h: 0,
            priceChangePercentage24h: 0,
            marketCap: 0,
            volume24h: 0,
            high24h: 0,
            low24h: 0,
            ath: 0,
            athChangePercentage: 0,
            circulatingSupply: 0,
            lastUpdated: Date()
        )
    }
}
