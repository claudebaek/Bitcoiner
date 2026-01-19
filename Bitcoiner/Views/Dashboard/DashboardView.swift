//
//  DashboardView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var currentQuote = BitcoinQuote.quoteOfTheDay
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading && viewModel.bitcoinPrice.price == 0 {
                        loadingView
                    } else {
                        // Price Card
                        PriceCardView(price: viewModel.bitcoinPrice)
                        
                        // Mini Fear & Greed
                        MiniFearGreedGauge(
                            value: viewModel.fearGreedIndex.value,
                            classification: viewModel.fearGreedIndex.classification
                        )
                        
                        // Quick Stats Grid
                        quickStatsSection
                        
                        // Full Fear & Greed Gauge
                        FearGreedGaugeView(fearGreedIndex: viewModel.fearGreedIndex)
                        
                        // Historical Prices - Time Machine
                        HistoricalPriceView(
                            collection: viewModel.historicalPrices,
                            currentPrice: viewModel.bitcoinPrice.price
                        ) {
                            viewModel.refreshHistoricalPrices()
                        }
                        
                        // Asset Comparison - BTC vs Gold vs Real Estate
                        AssetComparisonView(
                            currentBtcPrice: viewModel.bitcoinPrice.price,
                            historicalBtcPrices: viewModel.historicalPrices,
                            marketData: viewModel.marketData
                        )
                        
                        // US Debt & Dollar Purchasing Power
                        DebtCounterView(
                            debtData: viewModel.debtData,
                            currentBtcPrice: viewModel.bitcoinPrice.price
                        )
                        
                        // Hyperinflation Nations
                        HyperinflationCardView(inflationData: viewModel.inflationData)
                        
                        // Bitcoin Quote
                        QuoteCardView(quote: currentQuote, showRefreshButton: true) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentQuote = BitcoinQuote.random
                            }
                        }
                    }
                    
                    if let error = viewModel.error {
                        errorBanner(error)
                    }
                    
                    // Last refresh time
                    if let lastRefresh = viewModel.lastRefresh {
                        lastRefreshView(lastRefresh)
                    }
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Bitcoin")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.bitcoinOrange)
                            .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                            .animation(viewModel.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.loadData()
                viewModel.startAutoRefresh()
            }
            .onDisappear {
                viewModel.stopAutoRefresh()
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.bitcoinOrange))
                .scaleEffect(1.5)
            
            Text("Loading Bitcoin data...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quick Stats")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Circulating Supply",
                    value: formatSupply(viewModel.bitcoinPrice.circulatingSupply),
                    subtitle: "of 21M max",
                    icon: "circle.dotted",
                    iconColor: AppColors.bitcoinOrange
                )
                
                StatCard(
                    title: "Market Sentiment",
                    value: viewModel.fearGreedIndex.classification.rawValue,
                    icon: "brain.head.profile",
                    iconColor: viewModel.fearGreedIndex.classification.color
                )
            }
        }
    }
    
    // MARK: - Error Banner
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppColors.neutralYellow)
            
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Text("Retry")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.bitcoinOrange)
            }
        }
        .padding()
        .background(AppColors.neutralYellow.opacity(0.15))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Last Refresh View
    private func lastRefreshView(_ date: Date) -> some View {
        HStack {
            Spacer()
            Image(systemName: "clock")
                .font(.system(size: 10))
            Text("Last updated: \(date.timeAgo)")
                .font(.system(size: 11))
            Spacer()
        }
        .foregroundColor(AppColors.tertiaryText)
        .padding(.top, 8)
    }
    
    // MARK: - Helpers
    private func formatSupply(_ supply: Double) -> String {
        String(format: "%.2fM BTC", supply / 1_000_000)
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}
