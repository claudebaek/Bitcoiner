//
//  MiningData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation
import Combine

// MARK: - Mining Cost Data
struct MiningData: Identifiable {
    let id = UUID()
    let averageMiningCost: Double // in USD per BTC
    let electricityCost: Double // in USD per kWh (average)
    let networkHashRate: Double // in EH/s
    let difficulty: Double
    let blockReward: Double // in BTC
    let dailyRevenue: Double // in USD for average miner
    let profitMargin: Double // percentage
    let breakEvenPrice: Double // in USD
    let historicalCost: [MiningCostPoint]
    let lastUpdated: Date
    var minerEfficiency: Double = 25.0 // J/TH
    var overheadMultiplier: Double = 1.4 // Total cost multiplier
    var isRealData: Bool = false // Indicates if data is from real API
    
    var formattedMiningCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: averageMiningCost)) ?? "$0"
    }
    
    var formattedHashRate: String {
        if networkHashRate >= 1000 {
            return String(format: "%.1f ZH/s", networkHashRate / 1000)
        } else {
            return String(format: "%.1f EH/s", networkHashRate)
        }
    }
    
    var formattedDifficulty: String {
        if difficulty >= 1_000_000_000_000 {
            return String(format: "%.2fT", difficulty / 1_000_000_000_000)
        } else if difficulty >= 1_000_000_000 {
            return String(format: "%.2fB", difficulty / 1_000_000_000)
        } else {
            return String(format: "%.2fM", difficulty / 1_000_000)
        }
    }
    
    var formattedBreakEven: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: breakEvenPrice)) ?? "$0"
    }
    
    var isProfitable: Bool {
        profitMargin > 0
    }
    
    var profitStatus: String {
        if profitMargin > 50 {
            return "Highly Profitable"
        } else if profitMargin > 20 {
            return "Profitable"
        } else if profitMargin > 0 {
            return "Marginally Profitable"
        } else if profitMargin > -20 {
            return "At Risk"
        } else {
            return "Unprofitable"
        }
    }
    
    // Formatted electricity cost with efficiency info
    var formattedElectricityCostDetailed: String {
        String(format: "$%.3f/kWh @ %.1f J/TH", electricityCost, minerEfficiency)
    }
    
    static var placeholder: MiningData {
        MiningData(
            averageMiningCost: 0,
            electricityCost: 0,
            networkHashRate: 0,
            difficulty: 0,
            blockReward: 3.125,
            dailyRevenue: 0,
            profitMargin: 0,
            breakEvenPrice: 0,
            historicalCost: [],
            lastUpdated: Date(),
            minerEfficiency: 25.0,
            overheadMultiplier: 1.4,
            isRealData: false
        )
    }
    
    // Sample data for demonstration (based on typical 2024-2025 values post-halving)
    static var sampleData: MiningData {
        MiningData(
            averageMiningCost: 42_500,
            electricityCost: 0.05,
            networkHashRate: 650, // EH/s
            difficulty: 95_670_000_000_000,
            blockReward: 3.125, // Post 2024 halving
            dailyRevenue: 45_200,
            profitMargin: 128.5, // ((98000-42500)/42500)*100
            breakEvenPrice: 42_500,
            historicalCost: [
                MiningCostPoint(date: Calendar.current.date(byAdding: .month, value: -6, to: Date())!, cost: 38_000, btcPrice: 65_000),
                MiningCostPoint(date: Calendar.current.date(byAdding: .month, value: -5, to: Date())!, cost: 39_500, btcPrice: 71_000),
                MiningCostPoint(date: Calendar.current.date(byAdding: .month, value: -4, to: Date())!, cost: 40_200, btcPrice: 68_000),
                MiningCostPoint(date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!, cost: 41_000, btcPrice: 85_000),
                MiningCostPoint(date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, cost: 41_800, btcPrice: 92_000),
                MiningCostPoint(date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, cost: 42_200, btcPrice: 95_000),
                MiningCostPoint(date: Date(), cost: 42_500, btcPrice: 98_000),
            ],
            lastUpdated: Date(),
            minerEfficiency: 25.0,
            overheadMultiplier: 1.4,
            isRealData: false
        )
    }
}

// MARK: - Mining Settings Manager
class MiningSettingsManager: ObservableObject {
    static let shared = MiningSettingsManager()
    
    @Published var settings: MiningSettings {
        didSet {
            saveSettings()
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.miningSettings),
           let decoded = try? JSONDecoder().decode(MiningSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.miningSettings)
        }
    }
    
    func resetToDefault() {
        settings = .default
    }
    
    func applyPreset(_ preset: MiningSettings) {
        settings = preset
    }
}

struct MiningCostPoint: Identifiable {
    let id = UUID()
    let date: Date
    let cost: Double
    let btcPrice: Double
    
    var margin: Double {
        guard cost > 0 else { return 0 }
        return ((btcPrice - cost) / cost) * 100
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Mining Difficulty Adjustment
struct DifficultyAdjustment: Identifiable {
    let id = UUID()
    let currentDifficulty: Double
    let estimatedNextDifficulty: Double
    let blocksUntilAdjustment: Int
    let estimatedChangePercent: Double
    let estimatedAdjustmentDate: Date
    
    var formattedChange: String {
        let sign = estimatedChangePercent >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, estimatedChangePercent)
    }
    
    var daysUntilAdjustment: Int {
        let blocks = blocksUntilAdjustment
        let minutesPerBlock = 10.0
        let minutes = Double(blocks) * minutesPerBlock
        return Int(minutes / (60 * 24))
    }
    
    static var sample: DifficultyAdjustment {
        DifficultyAdjustment(
            currentDifficulty: 95_670_000_000_000,
            estimatedNextDifficulty: 98_140_000_000_000,
            blocksUntilAdjustment: 1247,
            estimatedChangePercent: 2.58,
            estimatedAdjustmentDate: Calendar.current.date(byAdding: .day, value: 9, to: Date())!
        )
    }
}
