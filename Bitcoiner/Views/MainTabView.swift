//
//  MainTabView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.title, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)
            
            MarketDataView()
                .tabItem {
                    Label(Tab.market.title, systemImage: Tab.market.icon)
                }
                .tag(Tab.market)
            
            PositionView()
                .tabItem {
                    Label(Tab.positions.title, systemImage: Tab.positions.icon)
                }
                .tag(Tab.positions)
            
            LearnView()
                .tabItem {
                    Label(Tab.learn.title, systemImage: Tab.learn.icon)
                }
                .tag(Tab.learn)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.bitcoinOrange)
        .onAppear {
            configureTabBarAppearance()
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
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .market: return "Market"
        case .positions: return "Positions"
        case .learn: return "Learn"
        case .settings: return "Settings"
        }
    }
    
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
