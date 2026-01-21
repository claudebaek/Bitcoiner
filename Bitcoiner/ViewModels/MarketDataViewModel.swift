//
//  MarketDataViewModel.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation
import Combine

@MainActor
final class MarketDataViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var miningData: MiningData = .placeholder
    @Published var currentBTCPrice: Double = 0
    @Published var isLoading = false
    @Published var error: String?
    @Published var lastRefresh: Date?
    @Published var miningSettings: MiningSettings = .default
    @Published var isMiningDataReal = false
    @Published var news: [BitcoinNews] = []
    @Published var isLoadingNews = false
    
    // MARK: - Private Properties
    private let coinGeckoService: CoinGeckoService
    private let miningService: MiningService
    private let settingsManager: MiningSettingsManager
    private let newsService: NewsService
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(coinGeckoService: CoinGeckoService = .shared,
         miningService: MiningService = .shared,
         settingsManager: MiningSettingsManager = .shared,
         newsService: NewsService = .shared) {
        self.coinGeckoService = coinGeckoService
        self.miningService = miningService
        self.settingsManager = settingsManager
        self.newsService = newsService
        self.miningSettings = settingsManager.settings
    }
    
    // MARK: - Public Methods
    func loadData() {
        refreshTask?.cancel()
        refreshTask = Task {
            await fetchAllData()
        }
    }
    
    func refresh() async {
        await fetchAllData()
    }
    
    // MARK: - Private Methods
    private func fetchAllData() async {
        isLoading = true
        error = nil
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchBTCPrice() }
            group.addTask { await self.fetchMiningData() }
            group.addTask { await self.fetchNews() }
        }
        
        isLoading = false
        lastRefresh = Date()
    }
    
    private func fetchNews() async {
        isLoadingNews = true
        do {
            news = try await newsService.fetchNews(limit: 5)
        } catch {
            print("News fetch error: \(error.localizedDescription)")
            // Keep existing news or empty if none
        }
        isLoadingNews = false
    }
    
    private func fetchBTCPrice() async {
        do {
            let priceData = try await coinGeckoService.fetchBitcoinPrice()
            currentBTCPrice = priceData.price
        } catch {
            // Use default price if fetch fails
            currentBTCPrice = 98000
        }
    }
    
    private func fetchMiningData() async {
        do {
            // Fetch real mining data using MiningService
            let data = try await miningService.fetchMiningData(
                settings: miningSettings,
                btcPrice: currentBTCPrice > 0 ? currentBTCPrice : 98000
            )
            miningData = data
            isMiningDataReal = true
        } catch {
            // Fallback to calculated sample data if API fails
            print("Mining API error: \(error.localizedDescription)")
            miningData = calculateFallbackMiningData()
            isMiningDataReal = false
        }
    }
    
    /// Calculates mining data using settings when API is unavailable
    private func calculateFallbackMiningData() -> MiningData {
        // Use estimated current network values
        let estimatedHashrate: Double = 750 // EH/s (Jan 2026 estimate)
        let estimatedDifficulty: Double = 110_000_000_000_000 // ~110T
        
        let calculation = miningService.calculateMiningCost(
            hashrate: estimatedHashrate,
            settings: miningSettings,
            btcPrice: currentBTCPrice > 0 ? currentBTCPrice : 98000
        )
        
        let price = currentBTCPrice > 0 ? currentBTCPrice : 98000
        let profitMargin = ((price - calculation.totalCostPerBTC) / calculation.totalCostPerBTC) * 100
        
        return MiningData(
            averageMiningCost: calculation.totalCostPerBTC,
            electricityCost: miningSettings.electricityRate,
            networkHashRate: estimatedHashrate,
            difficulty: estimatedDifficulty,
            blockReward: 3.125,
            dailyRevenue: price * calculation.dailyBTCMined / 1000,
            profitMargin: profitMargin,
            breakEvenPrice: calculation.totalCostPerBTC,
            historicalCost: MiningData.sampleData.historicalCost,
            lastUpdated: Date(),
            minerEfficiency: miningSettings.minerEfficiency,
            overheadMultiplier: miningSettings.overheadMultiplier,
            isRealData: false
        )
    }
    
    // MARK: - Mining Settings
    
    func updateMiningSettings(_ settings: MiningSettings) {
        miningSettings = settings
        settingsManager.settings = settings
        
        // Recalculate mining data with new settings
        Task {
            await fetchMiningData()
        }
    }
    
    func applyMiningPreset(_ preset: MiningSettings) {
        updateMiningSettings(preset)
    }
}
