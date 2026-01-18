//
//  QuoteCardView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import SwiftUI

struct QuoteCardView: View {
    let quote: BitcoinQuote
    var showRefreshButton: Bool = true
    var onRefresh: (() -> Void)?
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Bitcoin Wisdom")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                if showRefreshButton {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isAnimating = true
                        }
                        onRefresh?()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isAnimating = false
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                            .rotationEffect(.degrees(isAnimating ? 180 : 0))
                    }
                }
            }
            
            // Quote Text
            Text("\"\(quote.quote)\"")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .italic()
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            // Author
            HStack(spacing: 8) {
                // Bitcoin icon as avatar placeholder
                Circle()
                    .fill(AppColors.bitcoinOrange.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(quote.author.prefix(1)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.bitcoinOrange)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(quote.author)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    if let role = quote.role {
                        HStack(spacing: 4) {
                            Text(role)
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.secondaryText)
                            
                            if let year = quote.year {
                                Text("•")
                                    .foregroundColor(AppColors.tertiaryText)
                                Text("\(year)")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.tertiaryText)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(AppLayout.padding)
        .background(
            LinearGradient(
                colors: [
                    AppColors.cardBackground,
                    AppColors.cardBackground.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.cornerRadius)
                .stroke(AppColors.bitcoinOrange.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Compact Quote View (for smaller spaces)
struct CompactQuoteView: View {
    let quote: BitcoinQuote
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 20))
                .foregroundColor(AppColors.bitcoinOrange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(quote.quote)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(2)
                    .italic()
                
                Text("— \(quote.author)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Quote of the Day Banner
struct QuoteOfTheDayBanner: View {
    @State private var quote = BitcoinQuote.quoteOfTheDay
    @State private var showFullQuote = false
    
    var body: some View {
        Button {
            showFullQuote = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.neutralYellow)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quote of the Day")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppColors.neutralYellow)
                    
                    Text(quote.quote)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(12)
            .background(AppColors.neutralYellow.opacity(0.1))
            .cornerRadius(AppLayout.smallCornerRadius)
        }
        .sheet(isPresented: $showFullQuote) {
            QuoteDetailSheet(quote: quote)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Quote Detail Sheet
struct QuoteDetailSheet: View {
    let quote: BitcoinQuote
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Large quote icon
            Image(systemName: "quote.opening")
                .font(.system(size: 48))
                .foregroundColor(AppColors.bitcoinOrange)
            
            // Quote text
            Text(quote.quote)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
                .italic()
                .padding(.horizontal, 24)
            
            // Author info
            VStack(spacing: 4) {
                Text(quote.author)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                if let role = quote.role {
                    Text(role)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                if let year = quote.year {
                    Text("\(year)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            Spacer()
            
            // Share button
            ShareLink(item: "\"\(quote.quote)\" — \(quote.author)") {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Quote")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppColors.bitcoinOrange)
                .cornerRadius(AppLayout.cornerRadius)
            }
            .padding(.bottom, 24)
        }
        .background(AppColors.primaryBackground)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            QuoteCardView(quote: .random)
            
            CompactQuoteView(quote: .random)
            
            QuoteOfTheDayBanner()
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
