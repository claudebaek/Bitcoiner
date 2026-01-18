//
//  LiquidationData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

// MARK: - Binance Futures Liquidation Response
struct BinanceLiquidationResponse: Codable {
    let symbol: String
    let longAccount: String
    let longAccountRatio: String
    let shortAccount: String
    let shortAccountRatio: String
    let timestamp: Int64
}

// MARK: - App Models
struct LiquidationData: Identifiable {
    let id = UUID()
    let totalLiquidations24h: Double
    let longLiquidations: Double
    let shortLiquidations: Double
    let largestLiquidation: LiquidationEvent?
    let recentLiquidations: [LiquidationEvent]
    let heatmapData: [LiquidationHeatmapPoint]
    let lastUpdated: Date
    
    var longPercentage: Double {
        guard totalLiquidations24h > 0 else { return 50 }
        return (longLiquidations / totalLiquidations24h) * 100
    }
    
    var shortPercentage: Double {
        guard totalLiquidations24h > 0 else { return 50 }
        return (shortLiquidations / totalLiquidations24h) * 100
    }
    
    var formattedTotal: String {
        formatUSD(totalLiquidations24h)
    }
    
    var formattedLong: String {
        formatUSD(longLiquidations)
    }
    
    var formattedShort: String {
        formatUSD(shortLiquidations)
    }
    
    private func formatUSD(_ value: Double) -> String {
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let thousand = 1_000.0
        
        if value >= billion {
            return String(format: "$%.2fB", value / billion)
        } else if value >= million {
            return String(format: "$%.2fM", value / million)
        } else if value >= thousand {
            return String(format: "$%.1fK", value / thousand)
        } else {
            return String(format: "$%.0f", value)
        }
    }
    
    static var placeholder: LiquidationData {
        LiquidationData(
            totalLiquidations24h: 0,
            longLiquidations: 0,
            shortLiquidations: 0,
            largestLiquidation: nil,
            recentLiquidations: [],
            heatmapData: [],
            lastUpdated: Date()
        )
    }
}

struct LiquidationEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let side: PositionSide
    let amount: Double
    let price: Double
    let exchange: String
    
    var formattedAmount: String {
        if amount >= 1_000_000 {
            return String(format: "$%.2fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.1fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
    
    var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct LiquidationHeatmapPoint: Identifiable {
    let id = UUID()
    let priceLevel: Double
    let longLiquidations: Double
    let shortLiquidations: Double
    
    var totalLiquidations: Double {
        longLiquidations + shortLiquidations
    }
    
    var intensity: Double {
        // Normalize intensity for visualization (0-1)
        min(totalLiquidations / 10_000_000, 1.0)
    }
}

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
