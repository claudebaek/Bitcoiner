//
//  HistoricalPrice.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import Foundation
import SwiftUI

// MARK: - Historical Price Data
struct HistoricalPriceData: Identifiable {
    let id = UUID()
    let period: HistoricalPeriod
    let date: Date
    let price: Double
    let currentPrice: Double
    var isEstimated: Bool = false  // True if using fallback data
    
    var priceChange: Double {
        currentPrice - price
    }
    
    var priceChangePercentage: Double {
        guard price > 0 else { return 0 }
        return ((currentPrice - price) / price) * 100
    }
    
    var multiplier: Double {
        guard price > 0 else { return 0 }
        return currentPrice / price
    }
    
    var isPositive: Bool {
        priceChange >= 0
    }
    
    var formattedPrice: String {
        price.formattedCurrency
    }
    
    var formattedChange: String {
        let sign = priceChange >= 0 ? "+" : ""
        return "\(sign)\(priceChange.formattedCurrency)"
    }
    
    var formattedPercentage: String {
        let sign = priceChangePercentage >= 0 ? "+" : ""
        return String(format: "%@%.1f%%", sign, priceChangePercentage)
    }
    
    var formattedMultiplier: String {
        if multiplier >= 1 {
            return String(format: "%.1fx", multiplier)
        } else {
            return String(format: "%.2fx", multiplier)
        }
    }
}

// MARK: - Historical Period
enum HistoricalPeriod: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case oneYear = "1Y"
    case fourYears = "4Y"
    case tenYears = "10Y"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .oneMonth: return "1 Month"
        case .oneYear: return "1 Year"
        case .fourYears: return "4 Years"
        case .tenYears: return "10 Years"
        }
    }
    
    var shortName: String {
        rawValue
    }
    
    var date: Date {
        let calendar = Calendar.current
        switch self {
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        case .fourYears:
            return calendar.date(byAdding: .year, value: -4, to: Date()) ?? Date()
        case .tenYears:
            return calendar.date(byAdding: .year, value: -10, to: Date()) ?? Date()
        }
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    var icon: String {
        switch self {
        case .oneMonth: return "calendar"
        case .oneYear: return "calendar.circle"
        case .fourYears: return "bitcoinsign.circle" // Halving cycle
        case .tenYears: return "clock.arrow.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .oneMonth: return AppColors.secondaryText
        case .oneYear: return AppColors.neutralYellow
        case .fourYears: return AppColors.bitcoinOrange
        case .tenYears: return AppColors.profitGreen
        }
    }
}

// MARK: - CoinGecko Historical Response
struct CoinGeckoHistoricalResponse: Codable {
    let id: String
    let symbol: String
    let name: String
    let marketData: HistoricalMarketData?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case marketData = "market_data"
    }
}

struct HistoricalMarketData: Codable {
    let currentPrice: [String: Double]
    let marketCap: [String: Double]
    let totalVolume: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
    }
}

// MARK: - Historical Price Collection
struct HistoricalPriceCollection {
    var prices: [HistoricalPeriod: HistoricalPriceData] = [:]
    var isLoading: Bool = false
    var error: String?
    var lastUpdated: Date?
    
    var sortedPrices: [HistoricalPriceData] {
        HistoricalPeriod.allCases.compactMap { prices[$0] }
    }
    
    static var placeholder: HistoricalPriceCollection {
        HistoricalPriceCollection()
    }
}
