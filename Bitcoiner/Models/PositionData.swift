//
//  PositionData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

// MARK: - Position Side
enum PositionSide: String, Codable {
    case long = "LONG"
    case short = "SHORT"
    
    var color: String {
        switch self {
        case .long:
            return "00C853" // Green
        case .short:
            return "FF5252" // Red
        }
    }
    
    var icon: String {
        switch self {
        case .long:
            return "arrow.up.right"
        case .short:
            return "arrow.down.right"
        }
    }
}

// MARK: - Binance Long/Short Ratio Response
struct BinanceLongShortRatioResponse: Codable {
    let symbol: String
    let longShortRatio: String
    let longAccount: String
    let shortAccount: String
    let timestamp: Int64
}

// MARK: - Binance Top Trader Position Response
struct BinanceTopTraderPositionResponse: Codable {
    let symbol: String
    let longAccount: String
    let shortAccount: String
    let longShortRatio: String
    let timestamp: Int64
}

// MARK: - App Models
struct PositionData: Identifiable {
    let id = UUID()
    let longShortRatio: Double
    let longPercentage: Double
    let shortPercentage: Double
    let topTraderLongRatio: Double
    let topTraderShortRatio: Double
    let historicalData: [PositionHistoryPoint]
    let lastUpdated: Date
    
    var formattedRatio: String {
        String(format: "%.2f", longShortRatio)
    }
    
    var dominantSide: PositionSide {
        longShortRatio >= 1.0 ? .long : .short
    }
    
    var sentimentDescription: String {
        if longShortRatio > 1.5 {
            return "Strongly Bullish"
        } else if longShortRatio > 1.1 {
            return "Bullish"
        } else if longShortRatio >= 0.9 {
            return "Neutral"
        } else if longShortRatio >= 0.7 {
            return "Bearish"
        } else {
            return "Strongly Bearish"
        }
    }
    
    static var placeholder: PositionData {
        PositionData(
            longShortRatio: 1.0,
            longPercentage: 50,
            shortPercentage: 50,
            topTraderLongRatio: 50,
            topTraderShortRatio: 50,
            historicalData: [],
            lastUpdated: Date()
        )
    }
}

struct PositionHistoryPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let longShortRatio: Double
    let longPercentage: Double
    let shortPercentage: Double
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Open Interest Data
struct OpenInterestData: Identifiable {
    let id = UUID()
    let openInterest: Double
    let openInterestChange24h: Double
    let lastUpdated: Date
    
    var formattedOpenInterest: String {
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        
        if openInterest >= billion {
            return String(format: "$%.2fB", openInterest / billion)
        } else if openInterest >= million {
            return String(format: "$%.2fM", openInterest / million)
        } else {
            return String(format: "$%.0f", openInterest)
        }
    }
    
    var changeDirection: String {
        openInterestChange24h >= 0 ? "+" : ""
    }
    
    static var placeholder: OpenInterestData {
        OpenInterestData(
            openInterest: 0,
            openInterestChange24h: 0,
            lastUpdated: Date()
        )
    }
}

// MARK: - Funding Rate
struct FundingRateData: Identifiable {
    let id = UUID()
    let fundingRate: Double
    let nextFundingTime: Date
    let lastUpdated: Date
    
    var formattedRate: String {
        String(format: "%.4f%%", fundingRate * 100)
    }
    
    var sentiment: String {
        if fundingRate > 0.01 {
            return "Very Bullish"
        } else if fundingRate > 0 {
            return "Bullish"
        } else if fundingRate > -0.01 {
            return "Bearish"
        } else {
            return "Very Bearish"
        }
    }
    
    var timeUntilNextFunding: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: nextFundingTime, relativeTo: Date())
    }
    
    static var placeholder: FundingRateData {
        FundingRateData(
            fundingRate: 0,
            nextFundingTime: Date(),
            lastUpdated: Date()
        )
    }
}
