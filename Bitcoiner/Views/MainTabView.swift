//
//  MainTabView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab: Tab = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(L10n.tabDashboard, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)
            
            MarketDataView()
                .tabItem {
                    Label(L10n.tabMarket, systemImage: Tab.market.icon)
                }
                .tag(Tab.market)
            
            PositionView()
                .tabItem {
                    Label(L10n.tabPositions, systemImage: Tab.positions.icon)
                }
                .tag(Tab.positions)
            
            LearnView()
                .tabItem {
                    Label(L10n.tabLearn, systemImage: Tab.learn.icon)
                }
                .tag(Tab.learn)
            
            SettingsView()
                .tabItem {
                    Label(L10n.tabSettings, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.bitcoinOrange)
        .id(localizationManager.currentLanguage) // Force refresh on language change
        .onAppear {
            configureTabBarAppearance()
            // Log initial screen view
            AnalyticsManager.shared.logScreenView(screenName: selectedTab.rawValue.capitalized)
        }
        .onChange(of: selectedTab) { _, newTab in
            // Log screen view when tab changes
            AnalyticsManager.shared.logScreenView(screenName: newTab.rawValue.capitalized)
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.cardBackground)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.secondaryText)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.secondaryText)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.bitcoinOrange)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.bitcoinOrange)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Tab Enum
enum Tab: String, CaseIterable {
    case dashboard
    case market
    case positions
    case learn
    case settings
    
    var icon: String {
        switch self {
        case .dashboard: return "bitcoinsign.circle.fill"
        case .market: return "chart.bar.fill"
        case .positions: return "arrow.left.arrow.right"
        case .learn: return "book.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
