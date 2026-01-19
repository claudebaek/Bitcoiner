//
//  DashboardViewModel.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var bitcoinPrice: BitcoinPrice = .placeholder
    @Published var fearGreedIndex: FearGreedIndex = .placeholder
    @Published var historicalPrices: HistoricalPriceCollection = .placeholder
    @Published var marketData: MarketDataCollection = .placeholder
    @Published var debtData: DebtDataCollection = .placeholder
    @Published var inflationData: InflationDataCollection = InflationDataCollection()
    @Published var isLoading = false
    @Published var error: String?
    @Published var lastRefresh: Date?
    
    // MARK: - Private Properties
    private let coinGeckoService: CoinGeckoService
    private let fearGreedService: FearGreedService
    private let marketDataService: MarketDataService
    private let debtService: DebtService
    private let inflationService: InflationService
    private var refreshTask: Task<Void, Never>?
    private var autoRefreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(coinGeckoService: CoinGeckoService = .shared,
         fearGreedService: FearGreedService = .shared,
         marketDataService: MarketDataService = .shared,
         debtService: DebtService = .shared,
         inflationService: InflationService = .shared) {
        self.coinGeckoService = coinGeckoService
        self.fearGreedService = fearGreedService
        self.marketDataService = marketDataService
        self.debtService = debtService
        self.inflationService = inflationService
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
    
    func startAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(AppConstants.RefreshInterval.price * 1_000_000_000))
                if !Task.isCancelled {
                    await fetchBitcoinPrice()
                }
            }
        }
    }
    
    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }
    
    // MARK: - Private Methods
    private func fetchAllData() async {
        isLoading = true
        error = nil
        
        // First fetch current price, then fetch historical data
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchBitcoinPrice() }
            group.addTask { await self.fetchFearGreedIndex() }
            group.addTask { await self.fetchMarketData() }
            group.addTask { await self.fetchDebtData() }
            group.addTask { await self.fetchInflationData() }
        }
        
        // Fetch historical prices after we have current price
        await fetchHistoricalPrices()
        
        isLoading = false
        lastRefresh = Date()
    }
    
    private func fetchBitcoinPrice() async {
        do {
            bitcoinPrice = try await coinGeckoService.fetchBitcoinPrice()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func fetchFearGreedIndex() async {
        do {
            fearGreedIndex = try await fearGreedService.fetchCurrentIndex()
        } catch {
            // Don't overwrite error from price fetch
            if self.error == nil {
                self.error = error.localizedDescription
            }
        }
    }
    
    private func fetchHistoricalPrices() async {
        historicalPrices.isLoading = true
        let currentPrice = bitcoinPrice.price > 0 ? bitcoinPrice.price : 98000
        historicalPrices = await coinGeckoService.fetchAllHistoricalPrices(currentPrice: currentPrice)
    }
    
    private func fetchMarketData() async {
        marketData.isLoading = true
        marketData = await marketDataService.fetchAllMarketData()
    }
    
    private func fetchDebtData() async {
        debtData.isLoading = true
        debtData = await debtService.fetchAllDebtData()
    }
    
    private func fetchInflationData() async {
        inflationData.isLoading = true
        inflationData = await inflationService.fetchAllInflationData()
    }
    
    func refreshHistoricalPrices() {
        Task {
            await fetchHistoricalPrices()
        }
    }
    
    func refreshMarketData() {
        Task {
            await fetchMarketData()
        }
    }
    
    func refreshDebtData() {
        Task {
            await fetchDebtData()
        }
    }
}
