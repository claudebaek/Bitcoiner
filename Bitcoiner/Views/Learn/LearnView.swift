//
//  LearnView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct LearnView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection
                    
                    // Bitcoin Principles Diagram
                    NavigationLink(destination: BitcoinPrinciplesView()) {
                        LearnCard(
                            title: L10n.bitcoinPrinciples,
                            subtitle: L10n.bitcoinPrinciplesSubtitle,
                            icon: "bitcoinsign.circle.fill",
                            iconColor: AppColors.bitcoinOrange,
                            itemCount: 5,
                            itemLabel: L10n.concepts
                        )
                    }
                    
                    // Self-Custody Guide Card
                    NavigationLink(destination: SelfCustodyGuideView()) {
                        LearnCard(
                            title: L10n.selfCustodyGuide,
                            subtitle: L10n.selfCustodySubtitle,
                            icon: "key.fill",
                            iconColor: AppColors.bitcoinOrange,
                            itemCount: GuideSection.allSections.count,
                            itemLabel: L10n.topics
                        )
                    }
                    
                    // Wallet Recommendations Card
                    NavigationLink(destination: WalletListView()) {
                        LearnCard(
                            title: L10n.walletRecommendations,
                            subtitle: L10n.walletSubtitle,
                            icon: "wallet.pass.fill",
                            iconColor: AppColors.profitGreen,
                            itemCount: Wallet.allWallets.count,
                            itemLabel: L10n.wallets
                        )
                    }
                    
                    // Security Checklist Card
                    NavigationLink(destination: SecurityChecklistView()) {
                        LearnCard(
                            title: L10n.securityChecklist,
                            subtitle: L10n.securitySubtitle,
                            icon: "checkmark.shield.fill",
                            iconColor: AppColors.neutralYellow,
                            itemCount: SecurityCheckItem.allItems.count,
                            itemLabel: L10n.items
                        )
                    }
                    
                    // Korean Market Info Card
                    NavigationLink(destination: KoreanMarketInfoView()) {
                        LearnCard(
                            title: L10n.koreanMarketInfo,
                            subtitle: L10n.koreanMarketSubtitle,
                            icon: "wonsign.circle.fill",
                            iconColor: Color.blue,
                            itemCount: 3,
                            itemLabel: L10n.topics
                        )
                    }
                    
                    // Divider
                    dividerSection
                    
                    // Bitcoin Books Card
                    NavigationLink(destination: BookListView()) {
                        LearnCard(
                            title: L10n.bitcoinBooks,
                            subtitle: L10n.booksSubtitle,
                            icon: "books.vertical.fill",
                            iconColor: AppColors.profitGreen,
                            itemCount: BitcoinBook.allBooks.count,
                            itemLabel: L10n.books
                        )
                    }
                    
                    // YouTube Channels Card
                    NavigationLink(destination: YouTuberListView()) {
                        LearnCard(
                            title: L10n.youtubeChannels,
                            subtitle: L10n.youtubeSubtitle,
                            icon: "play.rectangle.fill",
                            iconColor: AppColors.lossRed,
                            itemCount: BitcoinYouTuber.allYouTubers.count,
                            itemLabel: L10n.channels
                        )
                    }
                    
                    // Quote
                    quoteSection
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle(L10n.learnTitle)
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.bitcoinOrange)
            
            Text(L10n.selfCustodyHeader)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text(L10n.notYourKeys)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.vertical, 24)
    }
    
    private var dividerSection: some View {
        HStack {
            VStack { Divider().background(AppColors.tertiaryText) }
            Text(L10n.education)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.tertiaryText)
                .padding(.horizontal, 8)
            VStack { Divider().background(AppColors.tertiaryText) }
        }
        .padding(.vertical, 8)
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
                    title: L10n.koreanExchanges,
                    icon: "building.columns.fill",
                    iconColor: AppColors.bitcoinOrange,
                    content: KoreanMarketInfo.exchangeInfo
                )
                
                // Tax Info
                InfoCard(
                    title: L10n.cryptoTaxKorea,
                    icon: "wonsign.circle.fill",
                    iconColor: AppColors.lossRed,
                    content: KoreanMarketInfo.taxInfo
                )
                
                // Travel Rule
                InfoCard(
                    title: L10n.travelRule,
                    icon: "airplane.circle.fill",
                    iconColor: AppColors.neutralYellow,
                    content: KoreanMarketInfo.travelRuleInfo
                )
                
                // Disclaimer
                Text(L10n.taxDisclaimer)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle(L10n.koreanMarketInfo)
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
