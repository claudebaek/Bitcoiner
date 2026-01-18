//
//  AssetComparisonView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import SwiftUI

// MARK: - Asset Comparison Card View
struct AssetComparisonView: View {
    let currentBtcPrice: Double
    var historicalBtcPrices: HistoricalPriceCollection = .placeholder
    var marketData: MarketDataCollection = .placeholder
    @State private var selectedPeriod: ComparisonPeriod = .fourYears
    @State private var showDetailSheet = false
    
    private var comparisons: [AssetComparisonResult] {
        AssetComparisonManager.shared.generateComparisons(
            currentBtcPrice: currentBtcPrice,
            historicalBtcPrices: historicalBtcPrices,
            marketData: marketData
        )
    }
    
    private var currentComparison: AssetComparisonResult? {
        comparisons.first { $0.period == selectedPeriod }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("BTC vs Other Assets")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button {
                    showDetailSheet = true
                } label: {
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            // Period Selector
            HStack(spacing: 8) {
                ForEach(ComparisonPeriod.allCases) { period in
                    PeriodButton(
                        period: period,
                        isSelected: selectedPeriod == period
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPeriod = period
                        }
                    }
                }
            }
            
            // Comparison Cards
            if let comparison = currentComparison {
                VStack(spacing: 8) {
                    // Bitcoin
                    ComparisonRow(
                        data: comparison.bitcoin,
                        isWinner: comparison.winner == .bitcoin
                    )
                    
                    // Divider with "vs" badge
                    HStack {
                        Rectangle()
                            .fill(AppColors.tertiaryText.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("vs")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppColors.tertiaryText)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .fill(AppColors.tertiaryText.opacity(0.3))
                            .frame(height: 1)
                    }
                    
                    // Gold
                    ComparisonRow(
                        data: comparison.gold,
                        isWinner: comparison.winner == .gold,
                        btcAdvantage: comparison.bitcoinVsGold
                    )
                    
                    // NASDAQ
                    ComparisonRow(
                        data: comparison.nasdaq,
                        isWinner: comparison.winner == .nasdaq,
                        btcAdvantage: comparison.bitcoinVsNasdaq
                    )
                    
                    // KOSPI
                    ComparisonRow(
                        data: comparison.kospi,
                        isWinner: comparison.winner == .kospi,
                        btcAdvantage: comparison.bitcoinVsKospi
                    )
                    
                    // Manhattan
                    ComparisonRow(
                        data: comparison.realEstate,
                        isWinner: comparison.winner == .realEstate,
                        btcAdvantage: comparison.bitcoinVsRealEstate
                    )
                    
                    // Dollar Index
                    ComparisonRow(
                        data: comparison.dollarIndex,
                        isWinner: comparison.winner == .dollarIndex,
                        btcAdvantage: comparison.bitcoinVsDollarIndex
                    )
                }
            }
            
            // Bottom hint
            HStack {
                Spacer()
                Text("Tap for details")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.tertiaryText)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .onTapGesture {
            showDetailSheet = true
        }
        .sheet(isPresented: $showDetailSheet) {
            AssetComparisonDetailSheet(
                currentBtcPrice: currentBtcPrice,
                comparisons: comparisons
            )
        }
    }
}

// MARK: - Period Button
struct PeriodButton: View {
    let period: ComparisonPeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? AppColors.primaryText : AppColors.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.bitcoinOrange : AppColors.secondaryBackground)
                .cornerRadius(AppLayout.smallCornerRadius)
        }
    }
}

// MARK: - Comparison Row
struct ComparisonRow: View {
    let data: AssetComparisonData
    let isWinner: Bool
    var btcAdvantage: Double? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Asset Icon
            Image(systemName: data.asset.icon)
                .font(.system(size: 20))
                .foregroundColor(data.asset.color)
                .frame(width: 32, height: 32)
                .background(data.asset.color.opacity(0.15))
                .cornerRadius(8)
            
            // Asset Name
            VStack(alignment: .leading, spacing: 2) {
                Text(data.asset.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                if let advantage = btcAdvantage, advantage > 0 {
                    Text("BTC +\(Int(advantage))% ahead")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.profitGreen)
                }
            }
            
            Spacer()
            
            // Returns
            VStack(alignment: .trailing, spacing: 2) {
                Text(data.formattedReturn)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(data.percentageReturn >= 0 ? AppColors.profitGreen : AppColors.lossRed)
                
                Text(data.formattedMultiplier)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            // Winner Badge
            if isWinner {
                Image(systemName: "crown.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.neutralYellow)
            }
        }
        .padding(10)
        .background(isWinner ? AppColors.bitcoinOrange.opacity(0.1) : AppColors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppLayout.smallCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppLayout.smallCornerRadius)
                .stroke(isWinner ? AppColors.bitcoinOrange.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Asset Comparison Detail Sheet
struct AssetComparisonDetailSheet: View {
    let currentBtcPrice: Double
    let comparisons: [AssetComparisonResult]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tab Selector
                    Picker("View", selection: $selectedTab) {
                        Text("Compare").tag(0)
                        Text("Real Estate").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if selectedTab == 0 {
                        comparisonView
                    } else {
                        realEstateView
                    }
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Asset Comparison")
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
    
    // MARK: - Comparison View
    private var comparisonView: some View {
        VStack(spacing: 16) {
            // Hero Section
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Bitcoin Outperforms")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("See how Bitcoin compares to traditional assets")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical)
            
            // All Period Comparisons
            ForEach(comparisons) { comparison in
                PeriodComparisonCard(comparison: comparison)
            }
            
            // Disclaimer
            Text("Historical data is approximate. Past performance does not guarantee future results.")
                .font(.system(size: 10))
                .foregroundColor(AppColors.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.top)
        }
    }
    
    // MARK: - Real Estate View
    private var realEstateView: some View {
        VStack(spacing: 16) {
            // Hero Section
            VStack(spacing: 8) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "4FC3F7"))
                
                Text("What If You Bought Bitcoin?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Compare Manhattan real estate vs. buying Bitcoin")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical)
            
            // Manhattan Property Card
            RealEstateComparisonCard(
                property: FamousRealEstate.manhattan,
                currentBtcPrice: currentBtcPrice
            )
        }
    }
}

// MARK: - Period Comparison Card
struct PeriodComparisonCard: View {
    let comparison: AssetComparisonResult
    
    private var maxReturn: Double {
        max(comparison.bitcoin.percentageReturn, 
            comparison.gold.percentageReturn,
            comparison.nasdaq.percentageReturn,
            comparison.kospi.percentageReturn,
            comparison.realEstate.percentageReturn,
            comparison.dollarIndex.percentageReturn,
            1)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(comparison.period.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(comparison.winner.color)
                    Text("\(comparison.winner.rawValue) Wins")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(comparison.winner.color)
                }
            }
            
            // Bar Chart Comparison
            VStack(spacing: 6) {
                AssetBarRow(data: comparison.bitcoin, maxReturn: maxReturn, isWinner: comparison.winner == .bitcoin)
                AssetBarRow(data: comparison.gold, maxReturn: maxReturn, isWinner: comparison.winner == .gold)
                AssetBarRow(data: comparison.nasdaq, maxReturn: maxReturn, isWinner: comparison.winner == .nasdaq)
                AssetBarRow(data: comparison.kospi, maxReturn: maxReturn, isWinner: comparison.winner == .kospi)
                AssetBarRow(data: comparison.realEstate, maxReturn: maxReturn, isWinner: comparison.winner == .realEstate)
                AssetBarRow(data: comparison.dollarIndex, maxReturn: maxReturn, isWinner: comparison.winner == .dollarIndex)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Asset Bar Row
struct AssetBarRow: View {
    let data: AssetComparisonData
    let maxReturn: Double
    var isWinner: Bool = false
    
    private var barWidth: CGFloat {
        guard maxReturn > 0 else { return 0 }
        return min(CGFloat(max(data.percentageReturn, 0) / maxReturn), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Asset Icon & Name
            HStack(spacing: 6) {
                Image(systemName: data.asset.icon)
                    .font(.system(size: 12))
                    .foregroundColor(data.asset.color)
                
                Text(data.asset.ticker)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
            }
            .frame(width: 60, alignment: .leading)
            
            // Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.secondaryBackground)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(data.asset.color)
                        .frame(width: geometry.size.width * barWidth)
                }
            }
            .frame(height: 20)
            
            // Percentage
            HStack(spacing: 4) {
                Text(data.formattedReturn)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(data.percentageReturn >= 0 ? AppColors.profitGreen : AppColors.lossRed)
                
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.neutralYellow)
                }
            }
            .frame(width: 80, alignment: .trailing)
        }
    }
}

// MARK: - Real Estate Comparison Card
struct RealEstateComparisonCard: View {
    let property: FamousRealEstate
    let currentBtcPrice: Double
    
    private var btcPriceAtPurchase: Double {
        HistoricalAssetPrices.bitcoinPrice(year: property.purchaseYear)
    }
    
    private var btcAmount: Double {
        property.btcAtPurchase(btcPriceAtPurchase: btcPriceAtPurchase)
    }
    
    private var btcValueNow: Double {
        property.btcValueToday(btcPriceAtPurchase: btcPriceAtPurchase, currentBtcPrice: currentBtcPrice)
    }
    
    private var btcReturn: Double {
        guard property.purchasePrice > 0 else { return 0 }
        return ((btcValueNow - property.purchasePrice) / property.purchasePrice) * 100
    }
    
    private var advantage: Double {
        btcValueNow - property.currentPrice
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Property Header
            HStack {
                Image(systemName: property.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "4FC3F7"))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: "4FC3F7").opacity(0.15))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(property.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("\(property.location) • \(property.purchaseYear)")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
            }
            
            Divider()
                .background(AppColors.tertiaryText.opacity(0.3))
            
            // Comparison Grid
            HStack(spacing: 16) {
                // Property Path
                VStack(spacing: 4) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "4FC3F7"))
                    
                    Text("Real Estate")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(property.formattedPurchasePrice)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text(property.formattedCurrentPrice)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(property.formattedReturn)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.profitGreen)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(AppLayout.smallCornerRadius)
                
                // VS Badge
                Text("VS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.tertiaryText)
                
                // Bitcoin Path
                VStack(spacing: 4) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.bitcoinOrange)
                    
                    Text("Bitcoin")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(String(format: "%.2f BTC", btcAmount))
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text(formatLargeNumber(btcValueNow))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.bitcoinOrange)
                    
                    Text(String(format: "+%.0f%%", btcReturn))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.profitGreen)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.bitcoinOrange.opacity(0.1))
                .cornerRadius(AppLayout.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppLayout.smallCornerRadius)
                        .stroke(AppColors.bitcoinOrange.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Advantage Banner
            if advantage > 0 {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.neutralYellow)
                    
                    Text("Bitcoin wins by ")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                    +
                    Text(formatLargeNumber(advantage))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.profitGreen)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(AppColors.profitGreen.opacity(0.1))
                .cornerRadius(AppLayout.smallCornerRadius)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private func formatLargeNumber(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        }
        return String(format: "$%.0f", value)
    }
}

// MARK: - Compact Asset Comparison (for inline use)
struct CompactAssetComparisonView: View {
    let currentBtcPrice: Double
    var marketData: MarketDataCollection = .placeholder
    
    private var fourYearComparison: AssetComparisonResult? {
        AssetComparisonManager.shared.generateComparisons(
            currentBtcPrice: currentBtcPrice,
            marketData: marketData
        ).first { $0.period == .fourYears }
    }
    
    var body: some View {
        if let comparison = fourYearComparison {
            HStack(spacing: 0) {
                // Bitcoin
                CompactAssetCell(data: comparison.bitcoin, isHighlighted: comparison.winner == .bitcoin)
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                // Gold
                CompactAssetCell(data: comparison.gold, isHighlighted: comparison.winner == .gold)
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                // NASDAQ
                CompactAssetCell(data: comparison.nasdaq, isHighlighted: comparison.winner == .nasdaq)
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                // KOSPI
                CompactAssetCell(data: comparison.kospi, isHighlighted: comparison.winner == .kospi)
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                // Real Estate (VNQ)
                CompactAssetCell(data: comparison.realEstate, isHighlighted: comparison.winner == .realEstate)
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                // Dollar Index (DXY)
                CompactAssetCell(data: comparison.dollarIndex, isHighlighted: comparison.winner == .dollarIndex)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.smallCornerRadius)
        }
    }
}

// MARK: - Compact Asset Cell
struct CompactAssetCell: View {
    let data: AssetComparisonData
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: data.asset.icon)
                    .font(.system(size: 10))
                    .foregroundColor(data.asset.color)
                
                Text(data.asset.ticker)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            Text(data.formattedReturn)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isHighlighted ? AppColors.bitcoinOrange : (data.percentageReturn >= 0 ? AppColors.profitGreen : AppColors.lossRed))
            
            Text("4Y")
                .font(.system(size: 8))
                .foregroundColor(AppColors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            AssetComparisonView(currentBtcPrice: 105000)
            CompactAssetComparisonView(currentBtcPrice: 105000)
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
