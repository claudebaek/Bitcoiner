//
//  MarketDataView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct MarketDataView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = MarketDataViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    MiningCostView(
                        miningData: viewModel.miningData, 
                        currentBTCPrice: viewModel.currentBTCPrice,
                        isRealData: viewModel.isMiningDataReal,
                        miningSettings: viewModel.miningSettings,
                        onSettingsChanged: { newSettings in
                            viewModel.updateMiningSettings(newSettings)
                        }
                    )
                    
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
            .navigationTitle(L10n.miningData)
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

#Preview {
    MarketDataView()
        .preferredColorScheme(.dark)
}
