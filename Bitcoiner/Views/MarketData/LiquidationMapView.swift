//
//  LiquidationMapView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct LiquidationMapView: View {
    let liquidationData: LiquidationData
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            headerSection
            
            // 24h Summary
            summarySection
            
            // Long vs Short bar
            longShortBarSection
            
            // Heatmap visualization
            heatmapSection
            
            // Premium data notice
            premiumDataNotice
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.lossRed)
            
            Text("Liquidations")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
            
            Text("24h")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.secondaryBackground)
                .cornerRadius(6)
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 8) {
                Text(liquidationData.formattedTotal)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Total Liquidated")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.bottom, 6)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                LiquidationStatBox(
                    title: "Longs",
                    value: liquidationData.formattedLong,
                    percentage: liquidationData.longPercentage,
                    color: AppColors.longColor
                )
                
                LiquidationStatBox(
                    title: "Shorts",
                    value: liquidationData.formattedShort,
                    percentage: liquidationData.shortPercentage,
                    color: AppColors.shortColor
                )
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Long Short Bar Section
    private var longShortBarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Liquidation Ratio")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            LiquidationBarChart(
                longLiquidations: liquidationData.longLiquidations,
                shortLiquidations: liquidationData.shortLiquidations
            )
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Heatmap Section
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Liquidation Heatmap")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                HStack(spacing: 8) {
                    LegendDot(label: "Long", color: AppColors.longColor)
                    LegendDot(label: "Short", color: AppColors.shortColor)
                }
            }
            
            if liquidationData.heatmapData.isEmpty {
                emptyHeatmapState
            } else {
                heatmapGrid
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var heatmapGrid: some View {
        VStack(spacing: 4) {
            ForEach(liquidationData.heatmapData.sorted(by: { $0.priceLevel > $1.priceLevel })) { point in
                HeatmapRow(point: point)
            }
        }
    }
    
    private var emptyHeatmapState: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            Text("Heatmap data unavailable")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }
    
    // MARK: - Premium Data Notice
    private var premiumDataNotice: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.neutralYellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Full Liquidation Map")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Detailed liquidation levels require Coinglass Pro API")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(AppLayout.padding)
        .background(AppColors.neutralYellow.opacity(0.1))
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Liquidation Stat Box
struct LiquidationStatBox: View {
    let title: String
    let value: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text(String(format: "%.1f%%", percentage))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppLayout.padding)
        .background(color.opacity(0.1))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Legend Dot
struct LegendDot: View {
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

// MARK: - Heatmap Row
struct HeatmapRow: View {
    let point: LiquidationHeatmapPoint
    
    private var maxLiq: Double {
        max(point.longLiquidations, point.shortLiquidations)
    }
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: point.priceLevel)) ?? "$0"
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Price label
            Text(formattedPrice)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(AppColors.secondaryText)
                .frame(width: 70, alignment: .trailing)
            
            // Bar
            GeometryReader { geometry in
                HStack(spacing: 1) {
                    // Long bar (left side, growing right)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.longColor.opacity(0.7 + point.intensity * 0.3))
                        .frame(width: max(geometry.size.width * 0.5 * normalizedLong, 2))
                    
                    Spacer()
                    
                    // Short bar (right side, growing left)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.shortColor.opacity(0.7 + point.intensity * 0.3))
                        .frame(width: max(geometry.size.width * 0.5 * normalizedShort, 2))
                }
            }
            .frame(height: 16)
        }
    }
    
    private var normalizedLong: Double {
        guard maxLiq > 0 else { return 0 }
        return point.longLiquidations / maxLiq
    }
    
    private var normalizedShort: Double {
        guard maxLiq > 0 else { return 0 }
        return point.shortLiquidations / maxLiq
    }
}

#Preview {
    ScrollView {
        LiquidationMapView(liquidationData: LiquidationData(
            totalLiquidations24h: 125_000_000,
            longLiquidations: 75_000_000,
            shortLiquidations: 50_000_000,
            largestLiquidation: nil,
            recentLiquidations: [],
            heatmapData: [
                LiquidationHeatmapPoint(priceLevel: 102000, longLiquidations: 3_000_000, shortLiquidations: 1_000_000),
                LiquidationHeatmapPoint(priceLevel: 101000, longLiquidations: 2_500_000, shortLiquidations: 1_500_000),
                LiquidationHeatmapPoint(priceLevel: 100000, longLiquidations: 2_000_000, shortLiquidations: 2_000_000),
                LiquidationHeatmapPoint(priceLevel: 99000, longLiquidations: 1_500_000, shortLiquidations: 2_500_000),
                LiquidationHeatmapPoint(priceLevel: 98000, longLiquidations: 1_000_000, shortLiquidations: 3_000_000),
            ],
            lastUpdated: Date()
        ))
        .padding()
    }
    .background(AppColors.primaryBackground)
}
