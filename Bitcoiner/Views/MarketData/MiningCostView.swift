//
//  MiningCostView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI
import Charts

struct MiningCostView: View {
    let miningData: MiningData
    let currentBTCPrice: Double
    let isRealData: Bool
    var miningSettings: MiningSettings
    var onSettingsChanged: ((MiningSettings) -> Void)?
    
    @State private var showSettings = false
    @State private var localSettings: MiningSettings = .default
    
    init(miningData: MiningData, 
         currentBTCPrice: Double, 
         isRealData: Bool = false,
         miningSettings: MiningSettings = .default,
         onSettingsChanged: ((MiningSettings) -> Void)? = nil) {
        self.miningData = miningData
        self.currentBTCPrice = currentBTCPrice
        self.isRealData = isRealData
        self.miningSettings = miningSettings
        self.onSettingsChanged = onSettingsChanged
        self._localSettings = State(initialValue: miningSettings)
    }
    
    private var profitMargin: Double {
        guard miningData.averageMiningCost > 0 else { return 0 }
        return ((currentBTCPrice - miningData.averageMiningCost) / miningData.averageMiningCost) * 100
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with mining cost
            headerSection
            
            // Cost breakdown
            costBreakdownSection
            
            // Profitability gauge
            profitabilitySection
            
            // Network stats
            networkStatsSection
            
            // Cost vs Price chart
            costChartSection
            
            // Data source notice
            dataSourceNotice
        }
        .sheet(isPresented: $showSettings) {
            MiningSettingsSheet(
                settings: $localSettings,
                onSave: { newSettings in
                    onSettingsChanged?(newSettings)
                    showSettings = false
                },
                onCancel: {
                    localSettings = miningSettings
                    showSettings = false
                }
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "cpu")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Mining Cost")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                // Data source indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(isRealData ? AppColors.profitGreen : AppColors.neutralYellow)
                        .frame(width: 8, height: 8)
                    
                    Text(isRealData ? "Live" : "Estimated")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isRealData ? AppColors.profitGreen : AppColors.neutralYellow)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.secondaryBackground)
                .cornerRadius(6)
                
                // Settings button
                Button {
                    localSettings = miningSettings
                    showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.bitcoinOrange)
                        .padding(8)
                        .background(AppColors.secondaryBackground)
                        .cornerRadius(8)
                }
            }
            
            HStack(alignment: .bottom, spacing: 16) {
                // Mining cost
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Cost per BTC")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(miningData.formattedMiningCost)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                }
                
                Spacer()
                
                // Current price comparison
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current BTC Price")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(currentBTCPrice.formattedCurrency)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Cost Breakdown Section
    private var costBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cost Breakdown")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            // Electricity cost component
            let electricityCost = miningData.averageMiningCost / miningSettings.overheadMultiplier
            let overheadCost = miningData.averageMiningCost - electricityCost
            
            VStack(spacing: 8) {
                CostBreakdownRow(
                    icon: "bolt.fill",
                    title: "Electricity Cost",
                    value: formatCurrency(electricityCost),
                    percentage: 100.0 / miningSettings.overheadMultiplier,
                    color: AppColors.neutralYellow
                )
                
                CostBreakdownRow(
                    icon: "building.2.fill",
                    title: "Overhead (Hardware, Labor, Cooling)",
                    value: formatCurrency(overheadCost),
                    percentage: (miningSettings.overheadMultiplier - 1) / miningSettings.overheadMultiplier * 100,
                    color: AppColors.lossRed
                )
                
                Divider()
                    .background(AppColors.tertiaryText)
                
                HStack {
                    Text("Total Production Cost")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text(miningData.formattedMiningCost)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                }
            }
            
            // Settings summary
            HStack(spacing: 16) {
                SettingsPill(title: "Elec.", value: String(format: "$%.3f", miningSettings.electricityRate))
                SettingsPill(title: "Eff.", value: String(format: "%.0f J/TH", miningSettings.minerEfficiency))
                SettingsPill(title: "Preset", value: miningSettings.presetName)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    // MARK: - Profitability Section
    private var profitabilitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Miner Profitability")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text(profitStatus)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(profitColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(profitColor.opacity(0.15))
                    .cornerRadius(8)
            }
            
            // Profit margin bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.secondaryBackground)
                        
                        // Profit bar
                        RoundedRectangle(cornerRadius: 8)
                            .fill(profitColor)
                            .frame(width: min(geometry.size.width * (min(profitMargin, 200) / 200), geometry.size.width))
                        
                        // Break-even marker
                        Rectangle()
                            .fill(AppColors.primaryText)
                            .frame(width: 2)
                            .offset(x: geometry.size.width * 0.5 - 1)
                    }
                }
                .frame(height: 24)
                
                HStack {
                    Text("-100%")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Break-even")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.secondaryText)
                        Text("0%")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    
                    Spacer()
                    
                    Text("+100%")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            // Margin value
            HStack {
                Text("Current Margin")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text(String(format: "%@%.1f%%", profitMargin >= 0 ? "+" : "", profitMargin))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(profitColor)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Network Stats Section
    private var networkStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Network Statistics")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NetworkStatBox(
                    icon: "speedometer",
                    title: "Hash Rate",
                    value: miningData.formattedHashRate,
                    color: AppColors.bitcoinOrange
                )
                
                NetworkStatBox(
                    icon: "slider.horizontal.3",
                    title: "Difficulty",
                    value: miningData.formattedDifficulty,
                    color: AppColors.neutralYellow
                )
                
                NetworkStatBox(
                    icon: "bitcoinsign.circle",
                    title: "Block Reward",
                    value: String(format: "%.3f BTC", miningData.blockReward),
                    color: AppColors.profitGreen
                )
                
                NetworkStatBox(
                    icon: "bolt",
                    title: "Electricity",
                    value: String(format: "$%.3f/kWh", miningData.electricityCost),
                    color: AppColors.lossRed
                )
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Cost Chart Section
    private var costChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mining Cost vs BTC Price")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            if miningData.historicalCost.isEmpty {
                emptyChartState
            } else {
                Chart {
                    ForEach(miningData.historicalCost) { point in
                        // BTC Price line
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Price", point.btcPrice),
                            series: .value("Type", "BTC Price")
                        )
                        .foregroundStyle(AppColors.bitcoinOrange)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        // Mining cost line
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Cost", point.cost),
                            series: .value("Type", "Mining Cost")
                        )
                        .foregroundStyle(AppColors.lossRed)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(monthFormat(date))
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.tertiaryText)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let price = value.as(Double.self) {
                                Text(String(format: "$%.0fK", price / 1000))
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.tertiaryText)
                            }
                        }
                    }
                }
                .chartLegend(position: .bottom) {
                    HStack(spacing: 16) {
                        LegendItem(color: AppColors.bitcoinOrange, label: "BTC Price")
                        LegendItem(color: AppColors.lossRed, label: "Mining Cost", isDashed: true)
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var emptyChartState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            Text("No historical data")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Data Source Notice
    private var dataSourceNotice: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mining Cost Calculation")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Network data from Mempool.space. Tap settings to adjust assumptions.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
            }
            
            // Formula explanation
            VStack(alignment: .leading, spacing: 4) {
                Text("Formula:")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppColors.tertiaryText)
                
                Text("Cost = (Hashrate × Efficiency × Electricity × Time) / BTC Mined × Overhead")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.bitcoinOrange.opacity(0.1))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Helper Properties
    private var profitStatus: String {
        if profitMargin > 50 {
            return "Highly Profitable"
        } else if profitMargin > 20 {
            return "Profitable"
        } else if profitMargin > 0 {
            return "Marginally Profitable"
        } else if profitMargin > -20 {
            return "At Risk"
        } else {
            return "Unprofitable"
        }
    }
    
    private var profitColor: Color {
        if profitMargin > 50 {
            return AppColors.profitGreen
        } else if profitMargin > 20 {
            return Color(hex: "81C784")
        } else if profitMargin > 0 {
            return AppColors.neutralYellow
        } else if profitMargin > -20 {
            return Color(hex: "FF8A65")
        } else {
            return AppColors.lossRed
        }
    }
    
    private func monthFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Network Stat Box
struct NetworkStatBox: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppLayout.padding)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String
    var isDashed: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            if isDashed {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(color)
                            .frame(width: 4, height: 2)
                    }
                }
                .frame(width: 16)
            } else {
                Rectangle()
                    .fill(color)
                    .frame(width: 16, height: 2)
            }
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

// MARK: - Cost Breakdown Row
struct CostBreakdownRow: View {
    let icon: String
    let title: String
    let value: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.secondaryBackground)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.opacity(0.6))
                            .frame(width: geometry.size.width * min(percentage / 100, 1.0))
                    }
                }
                .frame(height: 4)
            }
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(String(format: "%.0f%%", percentage))
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.tertiaryText)
            }
        }
    }
}

// MARK: - Settings Pill
struct SettingsPill: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(AppColors.tertiaryText)
            
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.secondaryBackground)
        .cornerRadius(8)
    }
}

// MARK: - Mining Settings Sheet
struct MiningSettingsSheet: View {
    @Binding var settings: MiningSettings
    var onSave: (MiningSettings) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Presets
                    presetsSection
                    
                    // Custom settings
                    customSettingsSection
                    
                    // Info
                    infoSection
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("Mining Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(AppColors.secondaryText)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onSave(settings)
                    }
                    .foregroundColor(AppColors.bitcoinOrange)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Presets")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: 12) {
                PresetButton(
                    title: "Efficient",
                    subtitle: "$0.03 / 17.5 J/TH",
                    isSelected: settings == .efficient,
                    color: AppColors.profitGreen
                ) {
                    settings = .efficient
                }
                
                PresetButton(
                    title: "Average",
                    subtitle: "$0.05 / 25 J/TH",
                    isSelected: settings == .average,
                    color: AppColors.neutralYellow
                ) {
                    settings = .average
                }
                
                PresetButton(
                    title: "Inefficient",
                    subtitle: "$0.08 / 35 J/TH",
                    isSelected: settings == .inefficient,
                    color: AppColors.lossRed
                ) {
                    settings = .inefficient
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var customSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Custom Settings")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            // Electricity Rate
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Electricity Rate")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text(String(format: "$%.3f/kWh", settings.electricityRate))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
                
                Slider(value: $settings.electricityRate, in: 0.01...0.15, step: 0.005)
                    .tint(AppColors.bitcoinOrange)
                
                HStack {
                    Text("$0.01")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    Spacer()
                    Text("$0.15")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            Divider().background(AppColors.tertiaryText)
            
            // Miner Efficiency
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Miner Efficiency")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f J/TH", settings.minerEfficiency))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
                
                Slider(value: $settings.minerEfficiency, in: 15...50, step: 0.5)
                    .tint(AppColors.bitcoinOrange)
                
                HStack {
                    Text("15 J/TH (New)")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    Spacer()
                    Text("50 J/TH (Old)")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            Divider().background(AppColors.tertiaryText)
            
            // Overhead Multiplier
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Overhead Multiplier")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text(String(format: "%.2fx", settings.overheadMultiplier))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
                
                Slider(value: $settings.overheadMultiplier, in: 1.0...2.0, step: 0.05)
                    .tint(AppColors.bitcoinOrange)
                
                HStack {
                    Text("1.0x (Elec. only)")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    Spacer()
                    Text("2.0x (High overhead)")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.neutralYellow)
                
                Text("Understanding the Parameters")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                InfoRow(title: "Electricity Rate:", description: "Cost per kWh. Miners in Texas/Kazakhstan pay ~$0.03, while others pay $0.08+")
                InfoRow(title: "Miner Efficiency:", description: "Joules per Terahash. New Antminer S21 = 17.5 J/TH, older S17 = 45 J/TH")
                InfoRow(title: "Overhead:", description: "Includes hardware depreciation, cooling, labor, and facility costs")
            }
        }
        .padding()
        .background(AppColors.neutralYellow.opacity(0.1))
        .cornerRadius(AppLayout.cornerRadius)
    }
}

// MARK: - Preset Button
struct PresetButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? AppColors.primaryText : AppColors.secondaryText)
                
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.tertiaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color.opacity(0.2) : AppColors.secondaryBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.secondaryText)
            
            Text(description)
                .font(.system(size: 10))
                .foregroundColor(AppColors.tertiaryText)
        }
    }
}

#Preview {
    ScrollView {
        MiningCostView(
            miningData: .sampleData, 
            currentBTCPrice: 98000,
            isRealData: true,
            miningSettings: .default
        )
        .padding()
    }
    .background(AppColors.primaryBackground)
}
