//
//  ETFFlowView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI
import Charts

struct ETFFlowView: View {
    let etfData: ETFData
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with total flow
            headerSection
            
            // Flow chart
            flowChartSection
            
            // ETF list
            etfListSection
            
            // Data source notice
            dataSourceNotice
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Bitcoin ETF Flow")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("Daily")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(6)
            }
            
            HStack(spacing: 20) {
                // Net Flow
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net Flow")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(etfData.formattedNetFlow)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(etfData.isNetInflow ? AppColors.profitGreen : AppColors.lossRed)
                }
                
                Spacer()
                
                // Total AUM
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total AUM")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(etfData.formattedAUM)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                }
            }
            
            // Flow direction indicator
            HStack(spacing: 8) {
                Image(systemName: etfData.isNetInflow ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(etfData.isNetInflow ? AppColors.profitGreen : AppColors.lossRed)
                
                Text(etfData.flowDirection)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(etfData.isNetInflow ? AppColors.profitGreen : AppColors.lossRed)
                
                Spacer()
                
                Text(etfData.isNetInflow ? "Bullish Signal" : "Bearish Signal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(12)
            .background((etfData.isNetInflow ? AppColors.profitGreen : AppColors.lossRed).opacity(0.1))
            .cornerRadius(8)
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Flow Chart Section
    private var flowChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7 Day Flow History")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            if etfData.historicalFlow.isEmpty {
                emptyChartState
            } else {
                Chart {
                    ForEach(etfData.historicalFlow) { point in
                        BarMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Flow", point.netFlow / 1_000_000)
                        )
                        .foregroundStyle(point.isPositive ? AppColors.profitGreen : AppColors.lossRed)
                        .cornerRadius(4)
                    }
                    
                    RuleMark(y: .value("Zero", 0))
                        .foregroundStyle(AppColors.secondaryText.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
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
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let flow = value.as(Double.self) {
                                Text(String(format: "$%.0fM", flow))
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.tertiaryText)
                            }
                        }
                    }
                }
                .frame(height: 150)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var emptyChartState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            Text("No historical data")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - ETF List Section
    private var etfListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ETF Breakdown")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("Daily Flow")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            if etfData.etfList.isEmpty {
                emptyListState
            } else {
                ForEach(etfData.etfList) { etf in
                    ETFRowView(etf: etf)
                    
                    if etf.id != etfData.etfList.last?.id {
                        Divider()
                            .background(AppColors.secondaryBackground)
                    }
                }
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var emptyListState: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            Text("No ETF data available")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Data Source Notice
    private var dataSourceNotice: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.bitcoinOrange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Data Source")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("ETF flow data is updated daily. Real-time data requires premium API access.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(AppLayout.padding)
        .background(AppColors.bitcoinOrange.opacity(0.1))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private func shortDayFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - ETF Row View
struct ETFRowView: View {
    let etf: ETFItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Ticker badge
            Text(etf.ticker)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(AppColors.bitcoinOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.bitcoinOrange.opacity(0.15))
                .cornerRadius(6)
            
            // ETF info
            VStack(alignment: .leading, spacing: 2) {
                Text(etf.issuer)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(etf.formattedHoldings)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            // Daily flow
            VStack(alignment: .trailing, spacing: 2) {
                Text(etf.formattedDailyFlow)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(etf.isInflow ? AppColors.profitGreen : AppColors.lossRed)
                
                Text(etf.formattedAUM)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScrollView {
        ETFFlowView(etfData: .sampleData)
            .padding()
    }
    .background(AppColors.primaryBackground)
}
