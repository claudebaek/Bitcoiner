//
//  BinanceService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

protocol BinanceServiceProtocol {
    func fetchLongShortRatio(period: String) async throws -> PositionData
}

final class BinanceService: BinanceServiceProtocol {
    static let shared = BinanceService()
    
    private let apiService: APIService
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Long/Short Ratio
    func fetchLongShortRatio(period: String = "5m") async throws -> PositionData {
        async let globalRatioTask: [BinanceLongShortRatioResponse] = apiService.fetch(
            from: AppConstants.API.longShortRatio(period: period)
        )
        
        async let topTraderRatioTask: [BinanceTopTraderPositionResponse] = apiService.fetch(
            from: AppConstants.API.topTraderLongShortRatio(period: period)
        )
        
        let (globalRatio, topTraderRatio) = try await (globalRatioTask, topTraderRatioTask)
        
        return mapToPositionData(globalRatio: globalRatio, topTraderRatio: topTraderRatio)
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
}
