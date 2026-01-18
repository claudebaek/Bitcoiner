//
//  ChartView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI
import Charts

// MARK: - Position History Chart
struct PositionHistoryChart: View {
    let data: [PositionHistoryPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("24h Long/Short History")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            if data.isEmpty {
                emptyState
            } else {
                chartContent
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var chartContent: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Ratio", point.longShortRatio)
                )
                .foregroundStyle(AppColors.bitcoinOrange)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                AreaMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Ratio", point.longShortRatio)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.bitcoinOrange.opacity(0.3), AppColors.bitcoinOrange.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // Reference line at 1.0
            RuleMark(y: .value("Neutral", 1.0))
                .foregroundStyle(AppColors.secondaryText.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.shortTime)
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let ratio = value.as(Double.self) {
                        Text(String(format: "%.2f", ratio))
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
        }
        .frame(height: 150)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            Text("No data available")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Fear Greed History Chart
struct FearGreedHistoryChart: View {
    let data: [FearGreedHistoryPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("7 Day History")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            if data.isEmpty {
                emptyState
            } else {
                chartContent
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var chartContent: some View {
        Chart {
            ForEach(data) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(colorForValue(point.value))
                .cornerRadius(4)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 7)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(shortDayFormat(date))
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisValueLabel {
                    if let val = value.as(Int.self) {
                        Text("\(val)")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
        }
        .frame(height: 120)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            Text("No data available")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
    
    private func colorForValue(_ value: Int) -> Color {
        FearGreedClassification.from(value: value).color
    }
    
    private func shortDayFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Liquidation Bar Chart
struct LiquidationBarChart: View {
    let longLiquidations: Double
    let shortLiquidations: Double
    
    private var total: Double {
        longLiquidations + shortLiquidations
    }
    
    private var longPercentage: Double {
        guard total > 0 else { return 50 }
        return (longLiquidations / total) * 100
    }
    
    private var shortPercentage: Double {
        guard total > 0 else { return 50 }
        return (shortLiquidations / total) * 100
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Stacked bar
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.longColor)
                        .frame(width: max(geometry.size.width * (longPercentage / 100), 20))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.shortColor)
                        .frame(width: max(geometry.size.width * (shortPercentage / 100), 20))
                }
            }
            .frame(height: 32)
            
            // Legend
            HStack {
                LiquidationLegendItem(
                    title: "Long Liquidated",
                    value: formatValue(longLiquidations),
                    percentage: longPercentage,
                    color: AppColors.longColor
                )
                
                Spacer()
                
                LiquidationLegendItem(
                    title: "Short Liquidated",
                    value: formatValue(shortLiquidations),
                    percentage: shortPercentage,
                    color: AppColors.shortColor,
                    alignment: .trailing
                )
            }
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
}

struct LiquidationLegendItem: View {
    let title: String
    let value: String
    let percentage: Double
    let color: Color
    var alignment: HorizontalAlignment = .leading
    
    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text(String(format: "%.1f%%", percentage))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(color)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            PositionHistoryChart(data: [])
            
            FearGreedHistoryChart(data: [])
            
            LiquidationBarChart(longLiquidations: 45_000_000, shortLiquidations: 55_000_000)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(AppLayout.cornerRadius)
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
