//
//  MarketDataView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

// MARK: - Market Tab Enum
enum MarketTab: String, CaseIterable {
    case mining
    case news
    
    var title: String {
        switch self {
        case .mining: return L10n.miningTab
        case .news: return L10n.newsTab
        }
    }
    
    var icon: String {
        switch self {
        case .mining: return "cpu"
        case .news: return "newspaper"
        }
    }
}

struct MarketDataView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = MarketDataViewModel()
    @State private var selectedTab: MarketTab = .mining
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                tabPicker
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    miningContent
                        .tag(MarketTab.mining)
                    
                    newsContent
                        .tag(MarketTab.news)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
            .background(AppColors.primaryBackground)
            .navigationTitle(L10n.marketTitle)
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
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - Tab Picker
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(MarketTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 14, weight: .medium))
                        Text(tab.title)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(selectedTab == tab ? AppColors.primaryText : AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.bitcoinOrange.opacity(0.15))
                            }
                        }
                    )
                    .overlay(
                        Rectangle()
                            .fill(selectedTab == tab ? AppColors.bitcoinOrange : Color.clear)
                            .frame(height: 2),
                        alignment: .bottom
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(AppColors.primaryBackground)
    }
    
    // MARK: - Mining Content
    private var miningContent: some View {
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
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - News Content
    private var newsContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // News Header
                newsHeader
                
                // News List
                if viewModel.isLoadingNews && viewModel.news.isEmpty {
                    newsLoadingView
                } else if viewModel.news.isEmpty {
                    newsEmptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.news) { item in
                            NewsCardView(news: item)
                        }
                    }
                }
                
                // Last refresh time
                if let lastRefresh = viewModel.lastRefresh {
                    lastRefreshView(lastRefresh)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - News Header
    private var newsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.bitcoinNews)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(L10n.latestNewsSubtitle)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            if viewModel.isLoadingNews {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(AppColors.bitcoinOrange)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - News Loading View
    private var newsLoadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.secondaryBackground)
                        .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.secondaryBackground)
                            .frame(height: 14)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.secondaryBackground)
                            .frame(width: 120, height: 10)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
            }
        }
        .redacted(reason: .placeholder)
    }
    
    // MARK: - News Empty State
    private var newsEmptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 48))
                .foregroundColor(AppColors.tertiaryText)
            
            Text(L10n.noNewsAvailable)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Text(L10n.retry)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColors.bitcoinOrange)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
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
