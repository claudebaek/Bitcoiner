//
//  LearnView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection
                    
                    // Self-Custody Guide Card
                    NavigationLink(destination: SelfCustodyGuideView()) {
                        LearnCard(
                            title: "Self-Custody Guide",
                            subtitle: "Learn why and how to hold your own keys",
                            icon: "key.fill",
                            iconColor: AppColors.bitcoinOrange,
                            itemCount: GuideSection.allSections.count,
                            itemLabel: "topics"
                        )
                    }
                    
                    // Wallet Recommendations Card
                    NavigationLink(destination: WalletListView()) {
                        LearnCard(
                            title: "Wallet Recommendations",
                            subtitle: "Hardware, software, and multisig options",
                            icon: "wallet.pass.fill",
                            iconColor: AppColors.profitGreen,
                            itemCount: Wallet.allWallets.count,
                            itemLabel: "wallets"
                        )
                    }
                    
                    // Security Checklist Card
                    NavigationLink(destination: SecurityChecklistView()) {
                        LearnCard(
                            title: "Security Checklist",
                            subtitle: "Essential steps to protect your Bitcoin",
                            icon: "checkmark.shield.fill",
                            iconColor: AppColors.neutralYellow,
                            itemCount: SecurityCheckItem.allItems.count,
                            itemLabel: "items"
                        )
                    }
                    
                    // Korean Market Info Card
                    NavigationLink(destination: KoreanMarketInfoView()) {
                        LearnCard(
                            title: "Korean Market Info",
                            subtitle: "Exchanges, taxes, and regulations in Korea",
                            icon: "wonsign.circle.fill",
                            iconColor: Color.blue,
                            itemCount: 3,
                            itemLabel: "topics"
                        )
                    }
                    
                    // Quote
                    quoteSection
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.bitcoinOrange)
            
            Text("Bitcoin Self-Custody")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text("Not your keys, not your coins")
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.vertical, 24)
    }
    
    private var quoteSection: some View {
        VStack(spacing: 12) {
            Text("\"The root problem with conventional currency is all the trust that's required to make it work.\"")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
                .italic()
            
            Text("— Satoshi Nakamoto")
                .font(.system(size: 12))
                .foregroundColor(AppColors.bitcoinOrange)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Learn Card
struct LearnCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let itemCount: Int
    let itemLabel: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(iconColor)
                .frame(width: 56, height: 56)
                .background(iconColor.opacity(0.15))
                .cornerRadius(12)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                Text("\(itemCount) \(itemLabel)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.tertiaryText)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Korean Market Info View
struct KoreanMarketInfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Exchange Info
                InfoCard(
                    title: "Korean Exchanges",
                    icon: "building.columns.fill",
                    iconColor: AppColors.bitcoinOrange,
                    content: KoreanMarketInfo.exchangeInfo
                )
                
                // Tax Info
                InfoCard(
                    title: "Crypto Tax in Korea",
                    icon: "wonsign.circle.fill",
                    iconColor: AppColors.lossRed,
                    content: KoreanMarketInfo.taxInfo
                )
                
                // Travel Rule
                InfoCard(
                    title: "Travel Rule",
                    icon: "airplane.circle.fill",
                    iconColor: AppColors.neutralYellow,
                    content: KoreanMarketInfo.travelRuleInfo
                )
                
                // Disclaimer
                Text("This information is for educational purposes only. Consult a tax professional for specific advice.")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle("Korean Market")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

#Preview {
    LearnView()
        .preferredColorScheme(.dark)
}
