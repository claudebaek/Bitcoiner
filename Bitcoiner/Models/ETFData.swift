//
//  ETFData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

// MARK: - ETF Flow Data
struct ETFData: Identifiable {
    let id = UUID()
    let totalNetFlow: Double // in USD
    let totalAUM: Double // Assets Under Management
    let etfList: [ETFItem]
    let historicalFlow: [ETFFlowPoint]
    let lastUpdated: Date
    
    var formattedNetFlow: String {
        formatUSD(totalNetFlow)
    }
    
    var formattedAUM: String {
        formatLargeUSD(totalAUM)
    }
    
    var isNetInflow: Bool {
        totalNetFlow >= 0
    }
    
    var flowDirection: String {
        isNetInflow ? "Net Inflow" : "Net Outflow"
    }
    
    private func formatUSD(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value >= 0 ? "+" : "-"
        
        if absValue >= 1_000_000_000 {
            return String(format: "%@$%.2fB", sign, absValue / 1_000_000_000)
        } else if absValue >= 1_000_000 {
            return String(format: "%@$%.2fM", sign, absValue / 1_000_000)
        } else if absValue >= 1_000 {
            return String(format: "%@$%.1fK", sign, absValue / 1_000)
        } else {
            return String(format: "%@$%.0f", sign, absValue)
        }
    }
    
    private func formatLargeUSD(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
    
    static var placeholder: ETFData {
        ETFData(
            totalNetFlow: 0,
            totalAUM: 0,
            etfList: [],
            historicalFlow: [],
            lastUpdated: Date()
        )
    }
    
    // Sample data for demonstration
    static var sampleData: ETFData {
        ETFData(
            totalNetFlow: 156_000_000,
            totalAUM: 58_500_000_000,
            etfList: [
                ETFItem(ticker: "IBIT", name: "iShares Bitcoin Trust", issuer: "BlackRock", dailyFlow: 98_000_000, totalAUM: 25_800_000_000, holdingsBTC: 265_000),
                ETFItem(ticker: "FBTC", name: "Fidelity Wise Origin Bitcoin", issuer: "Fidelity", dailyFlow: 45_000_000, totalAUM: 12_500_000_000, holdingsBTC: 128_500),
                ETFItem(ticker: "ARKB", name: "ARK 21Shares Bitcoin ETF", issuer: "ARK/21Shares", dailyFlow: 22_000_000, totalAUM: 3_200_000_000, holdingsBTC: 32_900),
                ETFItem(ticker: "BITB", name: "Bitwise Bitcoin ETF", issuer: "Bitwise", dailyFlow: 12_000_000, totalAUM: 2_400_000_000, holdingsBTC: 24_700),
                ETFItem(ticker: "GBTC", name: "Grayscale Bitcoin Trust", issuer: "Grayscale", dailyFlow: -21_000_000, totalAUM: 14_600_000_000, holdingsBTC: 150_200),
            ],
            historicalFlow: [
                ETFFlowPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, netFlow: 125_000_000),
                ETFFlowPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, netFlow: -45_000_000),
                ETFFlowPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, netFlow: 210_000_000),
                ETFFlowPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, netFlow: 88_000_000),
                ETFFlowPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, netFlow: -12_000_000),
                ETFFlowPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, netFlow: 178_000_000),
                ETFFlowPoint(date: Date(), netFlow: 156_000_000),
            ],
            lastUpdated: Date()
        )
    }
}

struct ETFItem: Identifiable {
    let id = UUID()
    let ticker: String
    let name: String
    let issuer: String
    let dailyFlow: Double
    let totalAUM: Double
    let holdingsBTC: Double
    
    var formattedDailyFlow: String {
        let absValue = abs(dailyFlow)
        let sign = dailyFlow >= 0 ? "+" : "-"
        
        if absValue >= 1_000_000 {
            return String(format: "%@$%.1fM", sign, absValue / 1_000_000)
        } else if absValue >= 1_000 {
            return String(format: "%@$%.0fK", sign, absValue / 1_000)
        } else {
            return String(format: "%@$%.0f", sign, absValue)
        }
    }
    
    var formattedAUM: String {
        if totalAUM >= 1_000_000_000 {
            return String(format: "$%.1fB", totalAUM / 1_000_000_000)
        } else if totalAUM >= 1_000_000 {
            return String(format: "$%.1fM", totalAUM / 1_000_000)
        } else {
            return String(format: "$%.0f", totalAUM)
        }
    }
    
    var formattedHoldings: String {
        if holdingsBTC >= 1_000 {
            return String(format: "%.1fK BTC", holdingsBTC / 1_000)
        } else {
            return String(format: "%.0f BTC", holdingsBTC)
        }
    }
    
    var isInflow: Bool {
        dailyFlow >= 0
    }
}

struct ETFFlowPoint: Identifiable {
    let id = UUID()
    let date: Date
    let netFlow: Double
    
    var isPositive: Bool {
        netFlow >= 0
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}
