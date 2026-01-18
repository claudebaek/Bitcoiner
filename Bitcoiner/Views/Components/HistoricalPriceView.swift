//
//  HistoricalPriceView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import SwiftUI

struct HistoricalPriceView: View {
    let collection: HistoricalPriceCollection
    let currentPrice: Double
    var onRefresh: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Time Machine")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                if collection.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let onRefresh = onRefresh {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            
            // Current price reference
            HStack {
                Text("Current Price:")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                
                Text(currentPrice.formattedCurrency)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.bitcoinOrange)
            }
            
            // Historical prices grid
            if collection.prices.isEmpty && !collection.isLoading {
                emptyState
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(HistoricalPeriod.allCases) { period in
                        if let data = collection.prices[period] {
                            HistoricalPriceCard(data: data)
                        } else {
                            HistoricalPricePlaceholder(period: period, isLoading: collection.isLoading)
                        }
                    }
                }
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            
            Text("Historical data unavailable")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }
}

// MARK: - Historical Price Card
struct HistoricalPriceCard: View {
    let data: HistoricalPriceData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Period header
            HStack {
                Image(systemName: data.period.icon)
                    .font(.system(size: 12))
                    .foregroundColor(data.period.color)
                
                Text(data.period.displayName + " Ago")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                // Estimated indicator
                if data.isEstimated {
                    Text("EST")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(AppColors.neutralYellow)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(AppColors.neutralYellow.opacity(0.2))
                        .cornerRadius(3)
                }
            }
            
            // Historical price
            Text(data.formattedPrice)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(data.isEstimated ? AppColors.secondaryText : AppColors.primaryText)
            
            // Change info
            HStack(spacing: 4) {
                // Percentage change
                Text(data.formattedPercentage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(data.isPositive ? AppColors.profitGreen : AppColors.lossRed)
                
                // Multiplier (if significant)
                if data.multiplier >= 1.5 || data.multiplier <= 0.5 {
                    Text("(\(data.formattedMultiplier))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(data.isPositive ? AppColors.profitGreen.opacity(0.8) : AppColors.lossRed.opacity(0.8))
                }
            }
            
            // Date
            Text(formatDate(data.date))
                .font(.system(size: 9))
                .foregroundColor(AppColors.tertiaryText)
        }
        .padding(12)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Placeholder Card
struct HistoricalPricePlaceholder: View {
    let period: HistoricalPeriod
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: period.icon)
                    .font(.system(size: 12))
                    .foregroundColor(period.color.opacity(0.5))
                
                Text(period.displayName + " Ago")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.tertiaryText)
                
                Spacer()
            }
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.7)
                    .frame(height: 20)
            } else {
                Text("--")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            Text("--")
                .font(.system(size: 12))
                .foregroundColor(AppColors.tertiaryText)
            
            Text("N/A")
                .font(.system(size: 9))
                .foregroundColor(AppColors.tertiaryText)
        }
        .padding(12)
        .background(AppColors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Compact Historical View (for inline display)
struct CompactHistoricalPriceView: View {
    let collection: HistoricalPriceCollection
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HistoricalPeriod.allCases) { period in
                if let data = collection.prices[period] {
                    VStack(spacing: 4) {
                        Text(period.shortName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(data.formattedPercentage)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(data.isPositive ? AppColors.profitGreen : AppColors.lossRed)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 4) {
                        Text(period.shortName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text("--")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if period != .tenYears {
                    Divider()
                        .frame(height: 24)
                        .background(AppColors.tertiaryText.opacity(0.3))
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Time Machine Detail Sheet
struct TimeMachineDetailSheet: View {
    let collection: HistoricalPriceCollection
    let currentPrice: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section
                    VStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.bitcoinOrange)
                        
                        Text("Bitcoin Time Machine")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("See how Bitcoin has performed over time")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding(.top, 20)
                    
                    // Current price
                    VStack(spacing: 4) {
                        Text("Current Price")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text(currentPrice.formattedCurrency)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppColors.bitcoinOrange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppLayout.cornerRadius)
                    
                    // Historical prices
                    ForEach(collection.sortedPrices) { data in
                        TimeMachineRow(data: data, currentPrice: currentPrice)
                    }
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.bitcoinOrange)
                }
            }
        }
    }
}

// MARK: - Time Machine Row
struct TimeMachineRow: View {
    let data: HistoricalPriceData
    let currentPrice: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Period info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: data.period.icon)
                            .foregroundColor(data.period.color)
                        
                        Text(data.period.displayName + " Ago")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    Text(formatDate(data.date))
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                // Price and change
                VStack(alignment: .trailing, spacing: 4) {
                    Text(data.formattedPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    HStack(spacing: 6) {
                        Text(data.formattedPercentage)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(data.isPositive ? AppColors.profitGreen : AppColors.lossRed)
                        
                        if data.multiplier >= 2 {
                            Text(data.formattedMultiplier)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.profitGreen)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            // Gain visualization
            if data.priceChange != 0 {
                HStack {
                    Text(data.isPositive ? "Gained" : "Lost")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(data.formattedChange)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(data.isPositive ? AppColors.profitGreen : AppColors.lossRed)
                    
                    Text("per BTC")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleCollection = HistoricalPriceCollection(prices: [
        .oneMonth: HistoricalPriceData(period: .oneMonth, date: Date().addingTimeInterval(-30*24*3600), price: 95000, currentPrice: 98000),
        .oneYear: HistoricalPriceData(period: .oneYear, date: Date().addingTimeInterval(-365*24*3600), price: 42000, currentPrice: 98000),
        .fourYears: HistoricalPriceData(period: .fourYears, date: Date().addingTimeInterval(-4*365*24*3600), price: 9000, currentPrice: 98000),
        .tenYears: HistoricalPriceData(period: .tenYears, date: Date().addingTimeInterval(-10*365*24*3600), price: 250, currentPrice: 98000)
    ])
    
    ScrollView {
        VStack(spacing: 16) {
            HistoricalPriceView(collection: sampleCollection, currentPrice: 98000)
            CompactHistoricalPriceView(collection: sampleCollection)
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
