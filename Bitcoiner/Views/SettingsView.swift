//
//  SettingsView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("autoRefreshEnabled") private var autoRefreshEnabled = true
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                // App Info Section
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.bitcoinOrange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bitcoiner")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("Bitcoin Market Intelligence")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.tertiaryText)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(AppColors.cardBackground)
                
                // General Settings
                Section("General") {
                    Toggle(isOn: $autoRefreshEnabled) {
                        SettingsRow(icon: "arrow.clockwise", title: "Auto Refresh", iconColor: AppColors.bitcoinOrange)
                    }
                    .tint(AppColors.bitcoinOrange)
                    
                    if autoRefreshEnabled {
                        Picker(selection: $refreshInterval) {
                            Text("15 seconds").tag(15)
                            Text("30 seconds").tag(30)
                            Text("1 minute").tag(60)
                            Text("5 minutes").tag(300)
                        } label: {
                            SettingsRow(icon: "timer", title: "Refresh Interval", iconColor: AppColors.profitGreen)
                        }
                    }
                    
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        SettingsRow(icon: "hand.tap", title: "Haptic Feedback", iconColor: AppColors.neutralYellow)
                    }
                    .tint(AppColors.bitcoinOrange)
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Data Sources Section
                Section("Data Sources") {
                    DataSourceRow(name: "CoinGecko", status: "Active", statusColor: AppColors.profitGreen, description: "Price & Market Data")
                    DataSourceRow(name: "Alternative.me", status: "Active", statusColor: AppColors.profitGreen, description: "Fear & Greed Index")
                    DataSourceRow(name: "Binance Futures", status: "Active", statusColor: AppColors.profitGreen, description: "Long/Short Ratio")
                    DataSourceRow(name: "CryptoQuant", status: "Premium", statusColor: AppColors.neutralYellow, description: "Exchange Reserves")
                    DataSourceRow(name: "Coinglass", status: "Premium", statusColor: AppColors.neutralYellow, description: "Liquidation Map")
                }
                .listRowBackground(AppColors.cardBackground)
                
                // About Section
                Section("About") {
                    Link(destination: URL(string: "https://github.com")!) {
                        SettingsRow(icon: "star.fill", title: "Rate App", iconColor: AppColors.neutralYellow)
                    }
                    
                    Link(destination: URL(string: "https://github.com")!) {
                        SettingsRow(icon: "envelope.fill", title: "Send Feedback", iconColor: AppColors.bitcoinOrange)
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        SettingsRow(icon: "hand.raised.fill", title: "Privacy Policy", iconColor: AppColors.secondaryText)
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        SettingsRow(icon: "doc.text.fill", title: "Terms of Service", iconColor: AppColors.secondaryText)
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Disclaimer
                Section {
                    Text("This app is for informational purposes only and should not be considered financial advice. Always do your own research before making investment decisions.")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.primaryBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.15))
                .cornerRadius(6)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(AppColors.primaryText)
        }
    }
}

// MARK: - Data Source Row
struct DataSourceRow: View {
    let name: String
    let status: String
    let statusColor: Color
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Text(status)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.15))
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Last updated: January 2026")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                
                policySection(title: "Information We Collect", content: "Bitcoiner does not collect, store, or share any personal information. All data displayed in the app is fetched from public APIs and is not stored on our servers.")
                
                policySection(title: "Third-Party Services", content: "We use third-party APIs (CoinGecko, Alternative.me, Binance) to fetch market data. Please refer to their respective privacy policies for information on how they handle data.")
                
                policySection(title: "Local Storage", content: "User preferences are stored locally on your device using standard iOS mechanisms. This data is not transmitted to any external servers.")
                
                policySection(title: "Contact", content: "If you have any questions about this Privacy Policy, please contact us.")
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Last updated: January 2026")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                
                termsSection(title: "Acceptance", content: "By using Bitcoiner, you agree to these Terms of Service.")
                
                termsSection(title: "Disclaimer", content: "The information provided in this app is for general informational purposes only. It should not be considered as financial, investment, or trading advice. Always consult with a qualified financial advisor before making investment decisions.")
                
                termsSection(title: "No Warranties", content: "The app is provided 'as is' without any warranties. We do not guarantee the accuracy, completeness, or reliability of the data displayed.")
                
                termsSection(title: "Limitation of Liability", content: "We shall not be liable for any damages arising from the use of this app or the information it provides.")
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
