//
//  HyperinflationCardView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

// MARK: - Hyperinflation Card View
struct HyperinflationCardView: View {
    let inflationData: InflationDataCollection
    
    @State private var selectedCategory: InflationCategory = .current
    @State private var showDetailSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.lossRed)
                
                Text("Fiat Currency Graveyard")
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
            
            // Category Picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(InflationCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            
            // Country Cards Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(casesForCategory) { caseItem in
                        CountryInflationCard(inflationCase: caseItem)
                    }
                }
            }
            
            // Stats Row
            if selectedCategory == .current {
                currentStatsRow
            } else {
                historicalStatsRow
            }
            
            // Bitcoin message
            HStack {
                Spacer()
                Text("21 million. Forever. ₿")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.bitcoinOrange)
                Spacer()
            }
            .padding(.top, 4)
            
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
            HyperinflationDetailSheet(inflationData: inflationData)
        }
    }
    
    // MARK: - Current Data Stats
    private var currentStats: (crisis: Int, severe: Int, high: Int, total: Int) {
        if inflationData.countries.isEmpty {
            return (HyperinflationStats.crisisCount, HyperinflationStats.severeCount, HyperinflationStats.highCount, HyperinflationStats.totalCountries)
        } else {
            return (inflationData.crisisCount, inflationData.severeCount, inflationData.highCount, inflationData.countries.count)
        }
    }
    
    // MARK: - Cases for Category
    private var casesForCategory: [HyperinflationCase] {
        switch selectedCategory {
        case .historical:
            return HyperinflationCase.historicalCases
        case .current:
            // Use API data if available, otherwise fall back to static data
            return inflationData.countries.isEmpty ? HyperinflationCase.currentCases : inflationData.countries
        }
    }
    
    // MARK: - Current Stats Row
    private var currentStatsRow: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                StatMiniBox(
                    value: "\(currentStats.crisis)",
                    label: "Crisis",
                    color: .red
                )
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                StatMiniBox(
                    value: "\(currentStats.severe)",
                    label: "Severe",
                    color: .orange
                )
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                StatMiniBox(
                    value: "\(currentStats.high)",
                    label: "High",
                    color: .yellow
                )
                
                Divider()
                    .frame(height: 30)
                    .background(AppColors.tertiaryText.opacity(0.3))
                
                StatMiniBox(
                    value: "\(currentStats.total)",
                    label: "Total",
                    color: AppColors.secondaryText
                )
            }
            
            // Data source indicator
            HStack(spacing: 4) {
                Image(systemName: inflationData.source == .api ? "checkmark.circle.fill" : "info.circle")
                    .font(.system(size: 9))
                    .foregroundColor(inflationData.source == .api ? AppColors.profitGreen : AppColors.tertiaryText)
                
                Text("Source: \(inflationData.sourceDescription)")
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(.vertical, 8)
        .background(AppColors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
    
    // MARK: - Historical Stats Row
    private var historicalStatsRow: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 12))
                .foregroundColor(AppColors.tertiaryText)
            
            Text("\(HyperinflationStats.historicalCount) major hyperinflation events in history")
                .font(.system(size: 11))
                .foregroundColor(AppColors.secondaryText)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppColors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Country Inflation Card
struct CountryInflationCard: View {
    let inflationCase: HyperinflationCase
    
    var body: some View {
        VStack(spacing: 6) {
            // Flag
            Text(inflationCase.flagEmoji)
                .font(.system(size: 32))
            
            // Country
            Text(inflationCase.country)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .lineLimit(1)
            
            // Inflation Rate
            Text(inflationCase.peakInflation)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(inflationCase.tier.color)
            
            // Year
            Text(inflationCase.year)
                .font(.system(size: 9))
                .foregroundColor(AppColors.tertiaryText)
        }
        .frame(width: 75)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Stat Mini Box
struct StatMiniBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppColors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Hyperinflation Detail Sheet
struct HyperinflationDetailSheet: View {
    let inflationData: InflationDataCollection
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: InflationCategory = .current
    
    private var currentCases: [HyperinflationCase] {
        inflationData.countries.isEmpty ? HyperinflationCase.currentCases : inflationData.countries
    }
    
    private var currentByTier: [InflationTier: [HyperinflationCase]] {
        if inflationData.countries.isEmpty {
            return HyperinflationCase.currentByTier
        } else {
            return inflationData.byTier
        }
    }
    
    private var totalCountries: Int {
        inflationData.countries.isEmpty ? HyperinflationStats.totalCountries : inflationData.countries.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Stats
                    headerSection
                    
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(InflationCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Cases List
                    if selectedCategory == .current {
                        currentCasesSection
                    } else {
                        historicalCasesSection
                    }
                    
                    // Bitcoin Solution
                    bitcoinSolutionSection
                    
                    // Disclaimer with source
                    VStack(spacing: 4) {
                        Text("Data from \(inflationData.sourceDescription)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(inflationData.source == .api ? AppColors.profitGreen : AppColors.tertiaryText)
                        
                        Text("Consumer price inflation (annual %). Last updated: \(inflationData.lastUpdated?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Fiat Failures")
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.lossRed)
            
            Text("Currency Destruction")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text("\(totalCountries) countries currently experiencing >15% inflation")
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK: - Current Cases Section
    private var currentCasesSection: some View {
        VStack(spacing: 16) {
            // Crisis Tier
            if let crisisCases = currentByTier[.crisis], !crisisCases.isEmpty {
                TierSection(title: "Crisis Level (>100%)", tier: .crisis, cases: crisisCases)
            }
            
            // Severe Tier
            if let severeCases = currentByTier[.severe], !severeCases.isEmpty {
                TierSection(title: "Severe (50-100%)", tier: .severe, cases: severeCases)
            }
            
            // High Tier
            if let highCases = currentByTier[.high], !highCases.isEmpty {
                TierSection(title: "High (15-50%)", tier: .high, cases: highCases)
            }
        }
    }
    
    // MARK: - Historical Cases Section
    private var historicalCasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Worst Hyperinflations in History")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            
            ForEach(HyperinflationCase.historicalCases) { caseItem in
                HistoricalCaseRow(inflationCase: caseItem)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Bitcoin Solution Section
    private var bitcoinSolutionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Bitcoin: The Exit")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                CheckmarkBulletPoint(text: "Fixed supply: 21 million max, ever")
                CheckmarkBulletPoint(text: "No central bank can print more")
                CheckmarkBulletPoint(text: "Transparent monetary policy")
                CheckmarkBulletPoint(text: "Borderless: escape capital controls")
                CheckmarkBulletPoint(text: "Self-custody: be your own bank")
            }
            
            // Adoption in high-inflation countries
            VStack(alignment: .leading, spacing: 8) {
                Text("Bitcoin adoption is highest in countries with:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                HStack(spacing: 8) {
                    AdoptionTag(text: "High inflation")
                    AdoptionTag(text: "Capital controls")
                    AdoptionTag(text: "Currency crises")
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Tier Section
struct TierSection: View {
    let title: String
    let tier: InflationTier
    let cases: [HyperinflationCase]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(tier.color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("\(cases.count) countries")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            ForEach(cases) { caseItem in
                CurrentCaseRow(inflationCase: caseItem)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Current Case Row
struct CurrentCaseRow: View {
    let inflationCase: HyperinflationCase
    
    var body: some View {
        HStack(spacing: 12) {
            Text(inflationCase.flagEmoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(inflationCase.country)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                
                Text(inflationCase.description)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.tertiaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(inflationCase.peakInflation)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(inflationCase.tier.color)
                
                Text(inflationCase.currency)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(10)
        .background(AppColors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Historical Case Row
struct HistoricalCaseRow: View {
    let inflationCase: HyperinflationCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(inflationCase.flagEmoji)
                    .font(.system(size: 28))
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(inflationCase.country)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(inflationCase.year)
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    
                    Text(inflationCase.currency)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Text(inflationCase.peakInflation)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.lossRed)
            }
            
            Text(inflationCase.description)
                .font(.system(size: 11))
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(2)
        }
        .padding(12)
        .background(AppColors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Checkmark Bullet Point
struct CheckmarkBulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(AppColors.profitGreen)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

// MARK: - Adoption Tag
struct AdoptionTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(AppColors.bitcoinOrange)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppColors.bitcoinOrange.opacity(0.15))
            .cornerRadius(4)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            HyperinflationCardView(inflationData: InflationDataCollection())
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
