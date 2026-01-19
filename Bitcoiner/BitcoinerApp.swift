//
//  BitcoinerApp.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

@main
struct BitcoinerApp: App {
    @State private var showLaunchScreen = true
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .preferredColorScheme(.dark)
                
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Dismiss launch screen after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
    
    private func configureAppearance() {
        // Navigation Bar Appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppColors.primaryBackground)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.bitcoinOrange)
        
        // Tab Bar Appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppColors.cardBackground)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // Refresh Control
        UIRefreshControl.appearance().tintColor = UIColor(AppColors.bitcoinOrange)
    }
}
