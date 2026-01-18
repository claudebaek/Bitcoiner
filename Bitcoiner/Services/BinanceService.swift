//
//  BinanceService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

protocol BinanceServiceProtocol {
    func fetchLongShortRatio() async throws -> PositionData
    func fetchLiquidationData() async throws -> LiquidationData
}

final class BinanceService: BinanceServiceProtocol {
    static let shared = BinanceService()
    
    private let apiService: APIService
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Long/Short Ratio
    func fetchLongShortRatio() async throws -> PositionData {
        async let globalRatioTask: [BinanceLongShortRatioResponse] = apiService.fetch(
            from: AppConstants.API.longShortRatio()
        )
        
        async let topTraderRatioTask: [BinanceTopTraderPositionResponse] = apiService.fetch(
            from: AppConstants.API.topTraderLongShortRatio()
        )
        
        let (globalRatio, topTraderRatio) = try await (globalRatioTask, topTraderRatioTask)
        
        return mapToPositionData(globalRatio: globalRatio, topTraderRatio: topTraderRatio)
    }
    
    // MARK: - Fetch Liquidation Data
    func fetchLiquidationData() async throws -> LiquidationData {
        // Note: Full liquidation data requires Coinglass API
        // Using Binance data to approximate
        let response: [BinanceLongShortRatioResponse] = try await apiService.fetch(
            from: AppConstants.API.topTraderPositionRatio()
        )
        
        return mapToLiquidationData(response)
    }
    
    // MARK: - Mapping Functions
    private func mapToPositionData(globalRatio: [BinanceLongShortRatioResponse], topTraderRatio: [BinanceTopTraderPositionResponse]) -> PositionData {
        guard let latest = globalRatio.first else {
            return .placeholder
        }
        
        let longShortRatio = Double(latest.longShortRatio) ?? 1.0
        let longPercentage = (Double(latest.longAccount) ?? 0.5) * 100
        let shortPercentage = (Double(latest.shortAccount) ?? 0.5) * 100
        
        // Top trader data
        let topTraderLong = topTraderRatio.first.flatMap { Double($0.longAccount) } ?? 0.5
        let topTraderShort = topTraderRatio.first.flatMap { Double($0.shortAccount) } ?? 0.5
        
        // Build historical data
        let historicalData = globalRatio.enumerated().compactMap { index, data -> PositionHistoryPoint? in
            guard let ratio = Double(data.longShortRatio),
                  let longPct = Double(data.longAccount),
                  let shortPct = Double(data.shortAccount) else {
                return nil
            }
            
            let timestamp = Date(timeIntervalSince1970: TimeInterval(data.timestamp / 1000))
            
            return PositionHistoryPoint(
                timestamp: timestamp,
                longShortRatio: ratio,
                longPercentage: longPct * 100,
                shortPercentage: shortPct * 100
            )
        }.reversed()
        
        return PositionData(
            longShortRatio: longShortRatio,
            longPercentage: longPercentage,
            shortPercentage: shortPercentage,
            topTraderLongRatio: topTraderLong * 100,
            topTraderShortRatio: topTraderShort * 100,
            historicalData: Array(historicalData),
            lastUpdated: Date()
        )
    }
    
    private func mapToLiquidationData(_ response: [BinanceLongShortRatioResponse]) -> LiquidationData {
        // Note: This is approximated data
        // Real liquidation data requires Coinglass or similar premium API
        
        guard let latest = response.first else {
            return .placeholder
        }
        
        let longRatio = Double(latest.longAccount) ?? 0.5
        let shortRatio = Double(latest.shortAccount) ?? 0.5
        
        // Simulated liquidation values based on ratio imbalance
        // In production, this would come from actual liquidation API
        let baseLiquidations = 50_000_000.0 // $50M base
        let longLiquidations = baseLiquidations * (1 - longRatio)
        let shortLiquidations = baseLiquidations * (1 - shortRatio)
        
        // Generate sample heatmap data
        let heatmapData = generateSampleHeatmapData()
        
        return LiquidationData(
            totalLiquidations24h: longLiquidations + shortLiquidations,
            longLiquidations: longLiquidations,
            shortLiquidations: shortLiquidations,
            largestLiquidation: nil,
            recentLiquidations: [],
            heatmapData: heatmapData,
            lastUpdated: Date()
        )
    }
    
    private func generateSampleHeatmapData() -> [LiquidationHeatmapPoint] {
        // Generate sample heatmap points
        // In production, this would come from actual data
        var points: [LiquidationHeatmapPoint] = []
        let basePrice = 100000.0 // Approximate BTC price
        
        for i in -5...5 {
            let priceLevel = basePrice + Double(i * 1000)
            let longLiq = Double.random(in: 0...5_000_000)
            let shortLiq = Double.random(in: 0...5_000_000)
            
            points.append(LiquidationHeatmapPoint(
                priceLevel: priceLevel,
                longLiquidations: longLiq,
                shortLiquidations: shortLiq
            ))
        }
        
        return points
    }
}
