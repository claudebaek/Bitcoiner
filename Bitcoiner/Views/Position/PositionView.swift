//
//  PositionView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct PositionView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = PositionViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Timeframe selector
                    timeframeSelector
                    
                    if viewModel.isLoading && viewModel.positionData.historicalData.isEmpty {
                        loadingView
                    } else {
                        // Long/Short ratio section
                        LongShortRatioView(positionData: viewModel.positionData)
                        
                        // Historical chart
                        PositionHistoryChart(data: viewModel.positionData.historicalData)
                        
                        // Additional stats
                        additionalStatsSection
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
            .navigationTitle(L10n.positionsTitle)
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
    
    // MARK: - Timeframe Selector
    private var timeframeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PositionTimeframe.allCases, id: \.self) { timeframe in
                    Button {
                        viewModel.selectTimeframe(timeframe)
                    } label: {
                        Text(timeframe.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(viewModel.selectedTimeframe == timeframe ? AppColors.primaryBackground : AppColors.secondaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedTimeframe == timeframe ?
                                AppColors.bitcoinOrange :
                                AppColors.cardBackground
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.bitcoinOrange))
                .scaleEffect(1.5)
            
            Text("Loading position data...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
    
    // MARK: - Additional Stats Section
    private var additionalStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Insights")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InsightCard(
                    icon: "arrow.up.arrow.down",
                    title: "Position Imbalance",
                    value: imbalanceValue,
                    color: imbalanceColor
                )
                
                InsightCard(
                    icon: "person.3.fill",
                    title: "Crowd Sentiment",
                    value: crowdSentiment,
                    color: AppColors.bitcoinOrange
                )
                
                InsightCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Risk Level",
                    value: riskLevel,
                    color: riskColor
                )
                
                InsightCard(
                    icon: "arrow.triangle.swap",
                    title: "Contrarian Signal",
                    value: contrarianSignal,
                    color: contrarianColor
                )
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Computed Properties
    private var imbalanceValue: String {
        let diff = abs(viewModel.positionData.longPercentage - viewModel.positionData.shortPercentage)
        return String(format: "%.1f%%", diff)
    }
    
    private var imbalanceColor: Color {
        let diff = abs(viewModel.positionData.longPercentage - viewModel.positionData.shortPercentage)
        if diff > 20 { return AppColors.lossRed }
        if diff > 10 { return AppColors.neutralYellow }
        return AppColors.profitGreen
    }
    
    private var crowdSentiment: String {
        if viewModel.positionData.longPercentage > 55 {
            return "Bullish"
        } else if viewModel.positionData.shortPercentage > 55 {
            return "Bearish"
        } else {
            return "Neutral"
        }
    }
    
    private var riskLevel: String {
        let ratio = viewModel.positionData.longShortRatio
        if ratio > 1.5 || ratio < 0.7 {
            return "High"
        } else if ratio > 1.2 || ratio < 0.8 {
            return "Medium"
        } else {
            return "Low"
        }
    }
    
    private var riskColor: Color {
        let ratio = viewModel.positionData.longShortRatio
        if ratio > 1.5 || ratio < 0.7 {
            return AppColors.lossRed
        } else if ratio > 1.2 || ratio < 0.8 {
            return AppColors.neutralYellow
        } else {
            return AppColors.profitGreen
        }
    }
    
    private var contrarianSignal: String {
        let ratio = viewModel.positionData.longShortRatio
        if ratio > 1.3 {
            return "Consider Short"
        } else if ratio < 0.8 {
            return "Consider Long"
        } else {
            return "No Signal"
        }
    }
    
    private var contrarianColor: Color {
        let ratio = viewModel.positionData.longShortRatio
        if ratio > 1.3 {
            return AppColors.shortColor
        } else if ratio < 0.8 {
            return AppColors.longColor
        } else {
            return AppColors.secondaryText
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
                Text(L10n.retry)
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
            Text("\(L10n.lastUpdated) \(date.timeAgo)")
                .font(.system(size: 11))
            Spacer()
        }
        .foregroundColor(AppColors.tertiaryText)
        .padding(.top, 8)
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppLayout.padding)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

#Preview {
    PositionView()
        .preferredColorScheme(.dark)
}
