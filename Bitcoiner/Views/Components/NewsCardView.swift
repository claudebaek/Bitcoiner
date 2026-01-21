//
//  NewsCardView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/22/26.
//

import SwiftUI

// MARK: - News Section View
struct NewsSectionView: View {
    let news: [BitcoinNews]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text(L10n.bitcoinNews)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(AppColors.bitcoinOrange)
                }
            }
            .padding(.horizontal)
            
            if news.isEmpty && !isLoading {
                emptyState
            } else {
                // News List
                LazyVStack(spacing: 12) {
                    ForEach(news) { item in
                        NewsCardView(news: item)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "newspaper")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            
            Text(L10n.noNewsAvailable)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - News Card View
struct NewsCardView: View {
    let news: BitcoinNews
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button {
            if let url = URL(string: news.url) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 12) {
                // News Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.secondaryBackground)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(news.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(news.source)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.bitcoinOrange)
                        
                        Text("•")
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(news.formattedDate)
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        NewsSectionView(
            news: [
                BitcoinNews(
                    id: "1",
                    title: "Bitcoin Breaks $100,000 for the First Time in History",
                    url: "https://example.com",
                    source: "CoinDesk",
                    publishedAt: Date().addingTimeInterval(-3600),
                    imageUrl: nil
                ),
                BitcoinNews(
                    id: "2",
                    title: "Institutional Investors Continue to Accumulate Bitcoin",
                    url: "https://example.com",
                    source: "Bloomberg",
                    publishedAt: Date().addingTimeInterval(-7200),
                    imageUrl: nil
                )
            ],
            isLoading: false
        )
    }
    .padding()
    .background(AppColors.primaryBackground)
    .preferredColorScheme(.dark)
}
