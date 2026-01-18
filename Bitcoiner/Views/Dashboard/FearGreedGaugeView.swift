//
//  FearGreedGaugeView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct FearGreedGaugeView: View {
    let fearGreedIndex: FearGreedIndex
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fear & Greed Index")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Crypto market sentiment")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Button {
                    showingDetail = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            // Main Gauge
            FearGreedGauge(
                value: fearGreedIndex.value,
                classification: fearGreedIndex.classification
            )
            
            // Scale labels
            HStack {
                Text("0")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.tertiaryText)
                
                Spacer()
                
                ForEach(FearGreedClassification.allCases, id: \.self) { classification in
                    Circle()
                        .fill(classification.color)
                        .frame(width: 8, height: 8)
                }
                
                Spacer()
                
                Text("100")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(.horizontal, 20)
            
            // Scale legend
            HStack(spacing: 0) {
                ForEach(FearGreedClassification.allCases, id: \.self) { classification in
                    VStack(spacing: 4) {
                        Text(classification.emoji)
                            .font(.system(size: 16))
                        Text(shortLabel(for: classification))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(classification.color)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Historical mini chart
            if !fearGreedIndex.historicalData.isEmpty {
                FearGreedHistoryChart(data: fearGreedIndex.historicalData)
            }
            
            // Last updated
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text("Updated: \(fearGreedIndex.timestamp.timeAgo)")
                    .font(.system(size: 11, weight: .regular))
            }
            .foregroundColor(AppColors.tertiaryText)
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
        .sheet(isPresented: $showingDetail) {
            FearGreedInfoSheet()
        }
    }
    
    private func shortLabel(for classification: FearGreedClassification) -> String {
        switch classification {
        case .extremeFear: return "Ext Fear"
        case .fear: return "Fear"
        case .neutral: return "Neutral"
        case .greed: return "Greed"
        case .extremeGreed: return "Ext Greed"
        }
    }
}

// MARK: - Fear Greed Info Sheet
struct FearGreedInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("The Fear and Greed Index analyzes emotions and sentiments from different sources and combines them into one simple number.")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        InfoItem(
                            range: "0-24",
                            title: "Extreme Fear",
                            description: "Investors are very worried. This can be a buying opportunity.",
                            color: FearGreedClassification.extremeFear.color
                        )
                        
                        InfoItem(
                            range: "25-44",
                            title: "Fear",
                            description: "Investors are getting fearful.",
                            color: FearGreedClassification.fear.color
                        )
                        
                        InfoItem(
                            range: "45-55",
                            title: "Neutral",
                            description: "Market sentiment is balanced.",
                            color: FearGreedClassification.neutral.color
                        )
                        
                        InfoItem(
                            range: "56-75",
                            title: "Greed",
                            description: "Investors are getting greedy.",
                            color: FearGreedClassification.greed.color
                        )
                        
                        InfoItem(
                            range: "76-100",
                            title: "Extreme Greed",
                            description: "Market is due for a correction.",
                            color: FearGreedClassification.extremeGreed.color
                        )
                    }
                    
                    Text("Data Sources")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Volatility (25%)")
                        BulletPoint(text: "Market Momentum/Volume (25%)")
                        BulletPoint(text: "Social Media (15%)")
                        BulletPoint(text: "Surveys (15%)")
                        BulletPoint(text: "Bitcoin Dominance (10%)")
                        BulletPoint(text: "Google Trends (10%)")
                    }
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Fear & Greed Index")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct InfoItem: View {
    let range: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(range)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppColors.bitcoinOrange)
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

#Preview {
    FearGreedGaugeView(fearGreedIndex: FearGreedIndex(
        value: 72,
        classification: .greed,
        timestamp: Date(),
        historicalData: []
    ))
    .padding()
    .background(AppColors.primaryBackground)
}
