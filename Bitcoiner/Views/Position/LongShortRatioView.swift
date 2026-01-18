//
//  LongShortRatioView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct LongShortRatioView: View {
    let positionData: PositionData
    
    var body: some View {
        VStack(spacing: 16) {
            // Main ratio card
            mainRatioCard
            
            // Long/Short gauge
            gaugeCard
            
            // Top trader comparison
            topTraderCard
        }
    }
    
    // MARK: - Main Ratio Card
    private var mainRatioCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Long/Short Ratio")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                // Sentiment badge
                SentimentBadge(sentiment: positionData.sentimentDescription, isLong: positionData.dominantSide == .long)
            }
            
            // Big ratio number
            HStack(alignment: .bottom, spacing: 12) {
                Text(positionData.formattedRatio)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(positionData.dominantSide == .long ? AppColors.longColor : AppColors.shortColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(positionData.dominantSide == .long ? "Longs Dominant" : "Shorts Dominant")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("BTCUSDT Perpetual")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Gauge Card
    private var gaugeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Position Distribution")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            LongShortGauge(
                longPercentage: positionData.longPercentage,
                shortPercentage: positionData.shortPercentage
            )
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Top Trader Card
    private var topTraderCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.neutralYellow)
                
                Text("Top Traders")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("vs Retail")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            HStack(spacing: 16) {
                TraderPositionBox(
                    title: "Top Trader Long",
                    percentage: positionData.topTraderLongRatio,
                    color: AppColors.longColor
                )
                
                TraderPositionBox(
                    title: "Top Trader Short",
                    percentage: positionData.topTraderShortRatio,
                    color: AppColors.shortColor
                )
            }
            
            // Comparison bar
            HStack(spacing: 8) {
                Text("Top Traders")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(width: 80, alignment: .leading)
                
                GeometryReader { geometry in
                    HStack(spacing: 1) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.longColor)
                            .frame(width: geometry.size.width * (positionData.topTraderLongRatio / 100))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.shortColor)
                    }
                }
                .frame(height: 12)
            }
            
            HStack(spacing: 8) {
                Text("All Accounts")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(width: 80, alignment: .leading)
                
                GeometryReader { geometry in
                    HStack(spacing: 1) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.longColor.opacity(0.6))
                            .frame(width: geometry.size.width * (positionData.longPercentage / 100))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.shortColor.opacity(0.6))
                    }
                }
                .frame(height: 12)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Sentiment Badge
struct SentimentBadge: View {
    let sentiment: String
    let isLong: Bool
    
    private var color: Color {
        isLong ? AppColors.longColor : AppColors.shortColor
    }
    
    var body: some View {
        Text(sentiment)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}

// MARK: - Trader Position Box
struct TraderPositionBox: View {
    let title: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(String(format: "%.1f", percentage))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
                
                Text("%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color.opacity(0.7))
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppLayout.padding)
        .background(color.opacity(0.1))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

#Preview {
    ScrollView {
        LongShortRatioView(positionData: PositionData(
            longShortRatio: 1.25,
            longPercentage: 55.6,
            shortPercentage: 44.4,
            topTraderLongRatio: 62.3,
            topTraderShortRatio: 37.7,
            historicalData: [],
            lastUpdated: Date()
        ))
        .padding()
    }
    .background(AppColors.primaryBackground)
}
