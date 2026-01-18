//
//  StatCard.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color
    let trend: TrendDirection?
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color = AppColors.bitcoinOrange,
        trend: TrendDirection? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                if let trend = trend {
                    TrendBadge(direction: trend)
                }
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(AppLayout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Trend Direction
enum TrendDirection {
    case up(Double)
    case down(Double)
    case neutral
    
    var color: Color {
        switch self {
        case .up:
            return AppColors.profitGreen
        case .down:
            return AppColors.lossRed
        case .neutral:
            return AppColors.neutralYellow
        }
    }
    
    var icon: String {
        switch self {
        case .up:
            return "arrow.up.right"
        case .down:
            return "arrow.down.right"
        case .neutral:
            return "arrow.right"
        }
    }
    
    var formattedValue: String {
        switch self {
        case .up(let value):
            return String(format: "+%.2f%%", value)
        case .down(let value):
            return String(format: "%.2f%%", value)
        case .neutral:
            return "0.00%"
        }
    }
}

// MARK: - Trend Badge
struct TrendBadge: View {
    let direction: TrendDirection
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: direction.icon)
                .font(.system(size: 10, weight: .bold))
            
            Text(direction.formattedValue)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(direction.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(direction.color.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Mini Stat Card
struct MiniStatCard: View {
    let title: String
    let value: String
    let valueColor: Color
    
    init(title: String, value: String, valueColor: Color = AppColors.primaryText) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(valueColor)
        }
        .padding(AppLayout.smallPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

#Preview {
    VStack(spacing: 16) {
        StatCard(
            title: "Bitcoin Price",
            value: "$98,234.56",
            subtitle: "Last updated: 2 min ago",
            icon: "bitcoinsign.circle.fill",
            iconColor: AppColors.bitcoinOrange,
            trend: .up(2.34)
        )
        
        StatCard(
            title: "Market Cap",
            value: "$1.92T",
            icon: "chart.pie.fill",
            trend: .down(-1.23)
        )
        
        HStack {
            MiniStatCard(title: "24h High", value: "$99,123")
            MiniStatCard(title: "24h Low", value: "$96,500")
        }
    }
    .padding()
    .background(AppColors.primaryBackground)
}
