//
//  MarketDataView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct MarketDataView: View {
    @StateObject private var viewModel = MarketDataViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                tabSelector
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        switch viewModel.selectedTab {
                        case .mining:
                            MiningCostView(
                                miningData: viewModel.miningData, 
                                currentBTCPrice: viewModel.currentBTCPrice,
                                isRealData: viewModel.isMiningDataReal,
                                miningSettings: viewModel.miningSettings,
                                onSettingsChanged: { newSettings in
                                    viewModel.updateMiningSettings(newSettings)
                                }
                            )
                            
                        case .exchanges:
                            ExchangeReserveView(exchangeData: viewModel.exchangeData)
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
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Market Data")
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
            }
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(MarketDataTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.quickSpring) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(viewModel.selectedTab == tab ? AppColors.bitcoinOrange : AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        viewModel.selectedTab == tab ?
                        AppColors.bitcoinOrange.opacity(0.1) :
                        Color.clear
                    )
                }
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .padding(.horizontal)
        .padding(.top, 8)
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
}

#Preview {
    MarketDataView()
        .preferredColorScheme(.dark)
}
