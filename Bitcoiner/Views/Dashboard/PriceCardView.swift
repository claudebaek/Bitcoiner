//
//  PriceCardView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct PriceCardView: View {
    let price: BitcoinPrice
    
    var body: some View {
        VStack(spacing: 16) {
            // Main price section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.bitcoinOrange)
                        
                        Text("Bitcoin")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("BTC")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Text(price.formattedPrice)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                }
                
                Spacer()
                
                // 24h change badge
                VStack(alignment: .trailing, spacing: 4) {
                    PriceChangeBadge(
                        change: price.priceChangePercentage24h,
                        isPositive: price.isPriceUp
                    )
                    
                    Text("24h")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            Divider()
                .background(AppColors.secondaryBackground)
            
            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PriceStatItem(title: "Market Cap", value: price.formattedMarketCap)
                PriceStatItem(title: "24h Volume", value: price.formattedVolume)
                PriceStatItem(title: "24h High", value: formatPrice(price.high24h), valueColor: AppColors.profitGreen)
                PriceStatItem(title: "24h Low", value: formatPrice(price.low24h), valueColor: AppColors.lossRed)
            }
            
            // ATH Section
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("All-Time High")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(price.formattedATH)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
                
                Spacer()
                
                Text(String(format: "%.1f%% from ATH", price.athChangePercentage))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.lossRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.lossRed.opacity(0.15))
                    .cornerRadius(6)
            }
            .padding(.top, 4)
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Price Change Badge
struct PriceChangeBadge: View {
    let change: Double
    let isPositive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 12, weight: .bold))
            
            Text(String(format: "%.2f%%", abs(change)))
                .font(.system(size: 16, weight: .bold))
        }
        .foregroundColor(isPositive ? AppColors.profitGreen : AppColors.lossRed)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background((isPositive ? AppColors.profitGreen : AppColors.lossRed).opacity(0.15))
        .cornerRadius(10)
    }
}

// MARK: - Price Stat Item
struct PriceStatItem: View {
    let title: String
    let value: String
    var valueColor: Color = AppColors.primaryText
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppColors.secondaryBackground)
        .cornerRadius(8)
    }
}

#Preview {
    PriceCardView(price: BitcoinPrice(
        price: 97234.56,
        priceChange24h: 1234.56,
        priceChangePercentage24h: 2.34,
        marketCap: 1_920_000_000_000,
        volume24h: 42_500_000_000,
        high24h: 98500,
        low24h: 95200,
        ath: 108000,
        athChangePercentage: -10.5,
        circulatingSupply: 19_500_000,
        lastUpdated: Date()
    ))
    .padding()
    .background(AppColors.primaryBackground)
}
