//
//  PositionViewModel.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation
import Combine

@MainActor
final class PositionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var positionData: PositionData = .placeholder
    @Published var isLoading = false
    @Published var error: String?
    @Published var lastRefresh: Date?
    @Published var selectedTimeframe: PositionTimeframe = .fiveMin
    
    // MARK: - Private Properties
    private let binanceService: BinanceService
    private var refreshTask: Task<Void, Never>?
    private var autoRefreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(binanceService: BinanceService = .shared) {
        self.binanceService = binanceService
    }
    
    // MARK: - Public Methods
    func loadData() {
        refreshTask?.cancel()
        refreshTask = Task {
            await fetchPositionData()
        }
    }
    
    func refresh() async {
        await fetchPositionData()
    }
    
    func startAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(AppConstants.RefreshInterval.positions * 1_000_000_000))
                if !Task.isCancelled {
                    await fetchPositionData()
                }
            }
        }
    }
    
    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }
    
    func selectTimeframe(_ timeframe: PositionTimeframe) {
        selectedTimeframe = timeframe
        loadData()
    }
    
    // MARK: - Private Methods
    private func fetchPositionData() async {
        isLoading = true
        error = nil
        
        do {
            positionData = try await binanceService.fetchLongShortRatio()
            lastRefresh = Date()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Position Timeframe
enum PositionTimeframe: String, CaseIterable {
    case fiveMin = "5m"
    case fifteenMin = "15m"
    case thirtyMin = "30m"
    case oneHour = "1h"
    case fourHour = "4h"
    case oneDay = "1d"
    
    var displayName: String {
        switch self {
        case .fiveMin: return "5 min"
        case .fifteenMin: return "15 min"
        case .thirtyMin: return "30 min"
        case .oneHour: return "1 hour"
        case .fourHour: return "4 hour"
        case .oneDay: return "1 day"
        }
    }
    
    var binanceValue: String {
        rawValue
    }
}
