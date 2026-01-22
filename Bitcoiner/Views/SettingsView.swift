//
//  SettingsView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var adManager = InterstitialAdManager.shared
    @AppStorage("autoRefreshEnabled") private var autoRefreshEnabled = true
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @Environment(\.requestReview) private var requestReview
    
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
                            Text(L10n.appName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.primaryText)
                            
                            Text(L10n.appTagline)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("\(L10n.version) 1.1.0")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.tertiaryText)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(AppColors.cardBackground)
                
                // General Settings
                Section(L10n.general) {
                    // Language Switcher
                    HStack {
                        SettingsRow(icon: "globe", title: L10n.language, iconColor: AppColors.profitGreen)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        localizationManager.setLanguage(language)
                                        // Log analytics
                                        AnalyticsManager.shared.logLanguageChanged(to: language.rawValue)
                                        AnalyticsManager.shared.setPreferredLanguage(language.rawValue)
                                    }
                                } label: {
                                    HStack {
                                        Text("\(language.flag) \(language.displayName)")
                                        if localizationManager.currentLanguage == language {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(localizationManager.currentLanguage.flag)
                                    .font(.system(size: 16))
                                Text(localizationManager.currentLanguage.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.bitcoinOrange)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.bitcoinOrange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.bitcoinOrange.opacity(0.15))
                            .cornerRadius(8)
                        }
                    }
                    
                    Toggle(isOn: $autoRefreshEnabled) {
                        SettingsRow(icon: "arrow.clockwise", title: L10n.autoRefresh, iconColor: AppColors.bitcoinOrange)
                    }
                    .tint(AppColors.bitcoinOrange)
                    
                    if autoRefreshEnabled {
                        Picker(selection: $refreshInterval) {
                            Text(L10n.seconds15).tag(15)
                            Text(L10n.seconds30).tag(30)
                            Text(L10n.minute1).tag(60)
                            Text(L10n.minutes5).tag(300)
                        } label: {
                            SettingsRow(icon: "timer", title: L10n.refreshInterval, iconColor: AppColors.profitGreen)
                        }
                    }
                    
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        SettingsRow(icon: "hand.tap", title: L10n.hapticFeedback, iconColor: AppColors.neutralYellow)
                    }
                    .tint(AppColors.bitcoinOrange)
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Data Sources Section
                Section(L10n.dataSources) {
                    DataSourceRow(name: "CoinGecko", status: L10n.active, statusColor: AppColors.profitGreen, description: L10n.priceData)
                    DataSourceRow(name: "Alternative.me", status: L10n.active, statusColor: AppColors.profitGreen, description: L10n.fearGreedIndex)
                    DataSourceRow(name: "Binance Futures", status: L10n.active, statusColor: AppColors.profitGreen, description: L10n.longShortRatio)
                    DataSourceRow(name: "CryptoQuant", status: L10n.premium, statusColor: AppColors.neutralYellow, description: L10n.exchangeReserves)
                    DataSourceRow(name: "Coinglass", status: L10n.premium, statusColor: AppColors.neutralYellow, description: "Liquidation Map")
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Support Section
                Section(L10n.supportDeveloper) {
                    Button {
                        adManager.showAd()
                    } label: {
                        HStack {
                            SettingsRow(icon: "gift.fill", title: L10n.watchAdSupport, iconColor: .pink)
                            
                            Spacer()
                            
                            if adManager.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else if adManager.isAdLoaded {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.profitGreen)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .disabled(!adManager.isAdLoaded && !adManager.isLoading)
                }
                .listRowBackground(AppColors.cardBackground)
                
                // About Section
                Section(L10n.about) {
                    Button {
                        requestReview()
                    } label: {
                        SettingsRow(icon: "star.fill", title: L10n.rateApp, iconColor: AppColors.neutralYellow)
                    }
                    
                    Link(destination: URL(string: "https://apps.apple.com/app/id6758008276?action=write-review")!) {
                        SettingsRow(icon: "pencil.and.outline", title: L10n.writeReview, iconColor: AppColors.profitGreen)
                    }
                    
                    ShareLink(item: URL(string: "https://apps.apple.com/app/id6758008276")!) {
                        SettingsRow(icon: "square.and.arrow.up", title: L10n.shareApp, iconColor: .blue)
                    }
                    
                    Link(destination: URL(string: "https://t.me/lijay100")!) {
                        SettingsRow(icon: "paperplane.fill", title: L10n.sendFeedback, iconColor: AppColors.bitcoinOrange)
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        SettingsRow(icon: "hand.raised.fill", title: L10n.privacyPolicy, iconColor: AppColors.secondaryText)
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        SettingsRow(icon: "doc.text.fill", title: L10n.termsOfService, iconColor: AppColors.secondaryText)
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Disclaimer
                Section {
                    Text(L10n.disclaimer)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.primaryBackground)
            .navigationTitle(L10n.settingsTitle)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                AnalyticsManager.shared.logEvent(.settingsViewed)
            }
            .overlay {
                if adManager.showThankYou {
                    ThankYouOverlay()
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: adManager.showThankYou)
        }
    }
}

// MARK: - Thank You Overlay
struct ThankYouOverlay: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(.pink)
            
            Text(L10n.thankYouSupport)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
            
            Text(L10n.thankYouMessage)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: .black.opacity(0.3), radius: 20)
        )
        .padding(40)
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
                Text("privacy_title".localized)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("privacy_updated".localized)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                
                policySection(title: "privacy_info_collect".localized, content: "privacy_info_collect_content".localized)
                
                policySection(title: "privacy_third_party".localized, content: "privacy_third_party_content".localized)
                
                policySection(title: "privacy_local_storage".localized, content: "privacy_local_storage_content".localized)
                
                policySection(title: "privacy_contact".localized, content: "privacy_contact_content".localized)
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
                Text("terms_title".localized)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("terms_updated".localized)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                
                termsSection(title: "terms_acceptance".localized, content: "terms_acceptance_content".localized)
                
                termsSection(title: "terms_disclaimer".localized, content: "terms_disclaimer_content".localized)
                
                termsSection(title: "terms_no_warranties".localized, content: "terms_no_warranties_content".localized)
                
                termsSection(title: "terms_limitation".localized, content: "terms_limitation_content".localized)
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
