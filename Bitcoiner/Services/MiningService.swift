//
//  MiningService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import Foundation

// MARK: - Mempool.space API Response Models

struct MempoolHashrateResponse: Codable {
    let hashrates: [HashrateDataPoint]
    let difficulty: [DifficultyDataPoint]
    let currentHashrate: Double
    let currentDifficulty: Double
}

struct HashrateDataPoint: Codable {
    let timestamp: Int
    let avgHashrate: Double
}

struct DifficultyDataPoint: Codable {
    let timestamp: Int
    let difficulty: Double
    let adjustment: Double
}

struct MempoolDifficultyAdjustment: Codable {
    let progressPercent: Double
    let difficultyChange: Double
    let estimatedRetargetDate: Int
    let remainingBlocks: Int
    let remainingTime: Int
    let previousRetarget: Double
    let nextRetargetHeight: Int
    let timeAvg: Int
    let timeOffset: Int
}

// MARK: - Mining Settings (User Configurable)

struct MiningSettings: Codable, Equatable {
    var electricityRate: Double      // $/kWh
    var minerEfficiency: Double      // J/TH (Joules per Terahash)
    var overheadMultiplier: Double   // Total cost = electricity * multiplier
    
    static let `default` = MiningSettings(
        electricityRate: 0.05,       // $0.05/kWh - global miner average
        minerEfficiency: 25.0,       // 25 J/TH - average fleet efficiency
        overheadMultiplier: 1.4      // 40% additional costs (hardware, cooling, labor)
    )
    
    // Preset configurations
    static let efficient = MiningSettings(
        electricityRate: 0.03,       // Cheap hydro/stranded gas
        minerEfficiency: 17.5,       // Latest Antminer S21 Pro
        overheadMultiplier: 1.3
    )
    
    static let average = MiningSettings(
        electricityRate: 0.05,
        minerEfficiency: 25.0,
        overheadMultiplier: 1.4
    )
    
    static let inefficient = MiningSettings(
        electricityRate: 0.08,       // Higher cost regions
        minerEfficiency: 35.0,       // Older generation ASICs
        overheadMultiplier: 1.5
    )
    
    var presetName: String {
        if self == .efficient { return "Efficient" }
        if self == .average { return "Average" }
        if self == .inefficient { return "Inefficient" }
        return "Custom"
    }
}

// MARK: - Mining Calculation Result

struct MiningCalculation {
    let electricityCostPerBTC: Double
    let totalCostPerBTC: Double
    let dailyNetworkEnergy: Double      // in TWh
    let dailyElectricityCost: Double    // in USD
    let dailyBTCMined: Double
    let annualizedCO2: Double           // in million tons (estimate)
    
    var formattedElectricityCost: String {
        formatCurrency(electricityCostPerBTC)
    }
    
    var formattedTotalCost: String {
        formatCurrency(totalCostPerBTC)
    }
    
    var formattedDailyEnergy: String {
        String(format: "%.2f TWh/day", dailyNetworkEnergy)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Mining Service

final class MiningService {
    static let shared = MiningService()
    
    private let apiService: APIService
    private let blockReward: Double = 3.125  // Post-April 2024 halving
    private let blocksPerDay: Double = 144
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Network Data
    
    /// Fetches current hashrate and difficulty from Mempool.space
    func fetchNetworkData() async throws -> (hashrate: Double, difficulty: Double) {
        let url = AppConstants.API.mempoolDifficultyAdjustment
        
        let response: MempoolDifficultyAdjustment = try await apiService.fetchWithCache(
            from: url,
            cacheDuration: AppConstants.CacheDuration.mining
        )
        
        // Fetch hashrate from hashrate endpoint
        let hashrateUrl = AppConstants.API.mempoolHashrate
        
        do {
            let hashrateData: [String: Any] = try await fetchRawJSON(from: hashrateUrl)
            if let currentHashrate = hashrateData["currentHashrate"] as? Double {
                // Convert from H/s to EH/s
                let hashrateEH = currentHashrate / 1e18
                
                // Get difficulty from difficulty adjustment response
                // We need to calculate current difficulty from the adjustment data
                let difficulty = try await fetchCurrentDifficulty()
                
                return (hashrateEH, difficulty)
            }
        } catch {
            // Fallback: estimate hashrate from difficulty
            let difficulty = try await fetchCurrentDifficulty()
            let estimatedHashrate = estimateHashrateFromDifficulty(difficulty)
            return (estimatedHashrate, difficulty)
        }
        
        throw APIError.noData
    }
    
    /// Fetches current difficulty
    private func fetchCurrentDifficulty() async throws -> Double {
        let url = AppConstants.API.mempoolDifficultyAdjustment
        let response: MempoolDifficultyAdjustment = try await apiService.fetch(from: url)
        
        // Calculate current difficulty from previous retarget and change
        // Note: previousRetarget is the % change of last adjustment, not the difficulty value
        // We need to fetch from a different endpoint or estimate
        
        // Fetch from blockchain stats
        let statsUrl = "https://mempool.space/api/v1/mining/hashrate/1d"
        do {
            if let data = try await fetchRawData(from: statsUrl),
               let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let difficulty = json["currentDifficulty"] as? Double {
                return difficulty
            }
        } catch {
            // Use fallback estimation
        }
        
        // Fallback: Use approximate current difficulty (Jan 2026 estimate)
        return 100_000_000_000_000  // ~100T
    }
    
    /// Fetches difficulty adjustment info
    func fetchDifficultyAdjustment() async throws -> DifficultyAdjustment {
        let url = AppConstants.API.mempoolDifficultyAdjustment
        let response: MempoolDifficultyAdjustment = try await apiService.fetchWithCache(
            from: url,
            cacheDuration: AppConstants.CacheDuration.mining
        )
        
        let currentDifficulty = try await fetchCurrentDifficulty()
        let estimatedNextDifficulty = currentDifficulty * (1 + response.difficultyChange / 100)
        
        return DifficultyAdjustment(
            currentDifficulty: currentDifficulty,
            estimatedNextDifficulty: estimatedNextDifficulty,
            blocksUntilAdjustment: response.remainingBlocks,
            estimatedChangePercent: response.difficultyChange,
            estimatedAdjustmentDate: Date(timeIntervalSince1970: TimeInterval(response.estimatedRetargetDate))
        )
    }
    
    // MARK: - Calculate Mining Cost
    
    /// Calculates mining cost based on network data and user settings
    func calculateMiningCost(
        hashrate: Double,         // in EH/s
        settings: MiningSettings,
        btcPrice: Double
    ) -> MiningCalculation {
        // Convert hashrate from EH/s to TH/s (1 EH = 1,000,000 TH)
        let hashrateTH = hashrate * 1_000_000
        
        // Calculate daily energy consumption
        // Energy (J) = Hashrate (TH/s) × Efficiency (J/TH) × Seconds per day
        let secondsPerDay: Double = 24 * 60 * 60
        let dailyEnergyJoules = hashrateTH * settings.minerEfficiency * secondsPerDay
        
        // Convert to kWh (1 kWh = 3,600,000 J)
        let dailyEnergyKWh = dailyEnergyJoules / 3_600_000
        
        // Convert to TWh for display
        let dailyEnergyTWh = dailyEnergyKWh / 1_000_000_000
        
        // Calculate daily electricity cost
        let dailyElectricityCost = dailyEnergyKWh * settings.electricityRate
        
        // Calculate daily BTC mined
        let dailyBTCMined = blocksPerDay * blockReward
        
        // Calculate cost per BTC
        let electricityCostPerBTC = dailyElectricityCost / dailyBTCMined
        let totalCostPerBTC = electricityCostPerBTC * settings.overheadMultiplier
        
        // Estimate annual CO2 (rough estimate: 0.5 kg CO2 per kWh global average)
        let annualEnergyKWh = dailyEnergyKWh * 365
        let annualCO2Tons = (annualEnergyKWh * 0.5) / 1_000_000  // Million tons
        
        return MiningCalculation(
            electricityCostPerBTC: electricityCostPerBTC,
            totalCostPerBTC: totalCostPerBTC,
            dailyNetworkEnergy: dailyEnergyTWh,
            dailyElectricityCost: dailyElectricityCost,
            dailyBTCMined: dailyBTCMined,
            annualizedCO2: annualCO2Tons
        )
    }
    
    /// Fetches complete mining data with calculations
    func fetchMiningData(settings: MiningSettings, btcPrice: Double) async throws -> MiningData {
        // Fetch real network data
        let (hashrate, difficulty) = try await fetchNetworkData()
        
        // Calculate mining costs
        let calculation = calculateMiningCost(
            hashrate: hashrate,
            settings: settings,
            btcPrice: btcPrice
        )
        
        // Calculate profit margin
        let profitMargin = ((btcPrice - calculation.totalCostPerBTC) / calculation.totalCostPerBTC) * 100
        
        // Fetch difficulty adjustment for historical context
        let diffAdjustment = try? await fetchDifficultyAdjustment()
        
        // Generate historical cost estimates (simplified - based on current settings)
        let historicalCost = generateHistoricalEstimates(
            currentCost: calculation.totalCostPerBTC,
            currentPrice: btcPrice
        )
        
        return MiningData(
            averageMiningCost: calculation.totalCostPerBTC,
            electricityCost: settings.electricityRate,
            networkHashRate: hashrate,
            difficulty: difficulty,
            blockReward: blockReward,
            dailyRevenue: btcPrice * calculation.dailyBTCMined / 1000, // Per 1 PH/s roughly
            profitMargin: profitMargin,
            breakEvenPrice: calculation.totalCostPerBTC,
            historicalCost: historicalCost,
            lastUpdated: Date()
        )
    }
    
    // MARK: - Helper Methods
    
    /// Estimates hashrate from difficulty (rough approximation)
    private func estimateHashrateFromDifficulty(_ difficulty: Double) -> Double {
        // Hashrate ≈ Difficulty × 2^32 / 600 (for 10-minute blocks)
        // Result is in H/s, convert to EH/s
        let hashrateHs = (difficulty * pow(2, 32)) / 600
        return hashrateHs / 1e18
    }
    
    /// Generates historical cost estimates for the chart
    private func generateHistoricalEstimates(currentCost: Double, currentPrice: Double) -> [MiningCostPoint] {
        var points: [MiningCostPoint] = []
        let calendar = Calendar.current
        
        // Generate 6 months of estimated data
        // Cost increases roughly with difficulty (simplified model)
        for i in (0...6).reversed() {
            guard let date = calendar.date(byAdding: .month, value: -i, to: Date()) else { continue }
            
            // Estimate: cost was lower in past due to lower difficulty
            // Rough estimate: ~3% monthly increase in difficulty/cost
            let monthsAgo = Double(i)
            let costFactor = pow(0.97, monthsAgo)
            let estimatedCost = currentCost * costFactor
            
            // Price fluctuations (simplified)
            let priceFactor = 1.0 + (Double.random(in: -0.15...0.15))
            let estimatedPrice = currentPrice * priceFactor * costFactor * 1.3
            
            points.append(MiningCostPoint(
                date: date,
                cost: estimatedCost,
                btcPrice: max(estimatedPrice, estimatedCost * 0.8)
            ))
        }
        
        // Add current point
        points.append(MiningCostPoint(
            date: Date(),
            cost: currentCost,
            btcPrice: currentPrice
        ))
        
        return points
    }
    
    /// Fetches raw JSON for complex parsing
    private func fetchRawJSON(from urlString: String) async throws -> [String: Any] {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decodingFailed(NSError(domain: "MiningService", code: -1))
        }
        
        return json
    }
    
    /// Fetches raw data
    private func fetchRawData(from urlString: String) async throws -> Data? {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
