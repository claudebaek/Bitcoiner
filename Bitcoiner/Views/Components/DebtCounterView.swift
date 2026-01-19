//
//  DebtCounterView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import SwiftUI
import Combine

// MARK: - Debt Counter Card View
struct DebtCounterView: View {
    let debtData: DebtDataCollection
    let currentBtcPrice: Double
    
    @State private var animatedDebt: Double = 0
    @State private var timer: AnyCancellable?
    @State private var showDetailSheet = false
    
    private var usDebt: USDebtData {
        debtData.usDebt ?? .placeholder
    }
    
    private var purchasingPower: DollarPurchasingPower {
        debtData.purchasingPower ?? .placeholder
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.lossRed)
                
                Text("US National Debt")
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
            
            // Real-time Debt Counter
            VStack(alignment: .leading, spacing: 4) {
                Text(formatAnimatedDebt(animatedDebt))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.lossRed)
                    .contentTransition(.numericText())
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.lossRed)
                    
                    Text("+$\(Int(usDebt.perSecondIncrease).formatted())/sec")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.lossRed)
                    
                    Text("•")
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text("$\(Int(usDebt.dailyIncreaseRate / 1_000_000_000))B/day")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            Divider()
                .background(AppColors.tertiaryText.opacity(0.3))
            
            // Quick Stats Row
            HStack(spacing: 16) {
                // Debt per citizen
                VStack(alignment: .leading, spacing: 2) {
                    Text("Per Citizen")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text(usDebt.formattedDebtPerCitizen)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                }
                
                Spacer()
                
                // Debt in BTC
                VStack(alignment: .trailing, spacing: 2) {
                    Text("In BTC Terms")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text(usDebt.formattedDebtInBTC(btcPrice: currentBtcPrice))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.bitcoinOrange)
                }
            }
            
            // Dollar Purchasing Power Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.neutralYellow)
                    
                    Text("Dollar Purchasing Power")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                // Progress bar showing value loss
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background (full width = original value)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.secondaryBackground)
                        
                        // Remaining value
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.lossRed)
                            .frame(width: geometry.size.width * CGFloat(1 - purchasingPower.purchasingPowerRemaining))
                        
                        // Labels
                        HStack {
                            Text(purchasingPower.formattedPercentageLost + " lost")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Text("\(purchasingPower.formattedDollarValueToday) left")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.tertiaryText)
                                .padding(.trailing, 8)
                        }
                    }
                }
                .frame(height: 24)
                
                // 1913 vs Today comparison
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$1 in 1913")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text("= \(purchasingPower.formattedDollarValueToday) today")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.lossRed)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$1 today")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text("= \(purchasingPower.formattedEquivalentToday) in 1913")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                    }
                }
            }
            .padding(10)
            .background(AppColors.secondaryBackground.opacity(0.5))
            .cornerRadius(AppLayout.smallCornerRadius)
            
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
        .onAppear {
            startDebtAnimation()
        }
        .onDisappear {
            stopDebtAnimation()
        }
        .onChange(of: debtData.usDebt?.totalDebt) { _, newValue in
            // Restart animation when real data loads
            if newValue != nil {
                restartDebtAnimation()
            }
        }
        .onTapGesture {
            showDetailSheet = true
        }
        .sheet(isPresented: $showDetailSheet) {
            DebtDetailSheet(
                debtData: debtData,
                currentBtcPrice: currentBtcPrice
            )
        }
    }
    
    // MARK: - Animation
    private func startDebtAnimation() {
        animatedDebt = usDebt.interpolatedDebt()
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                withAnimation(.linear(duration: 0.1)) {
                    animatedDebt = usDebt.interpolatedDebt()
                }
            }
    }
    
    private func stopDebtAnimation() {
        timer?.cancel()
        timer = nil
    }
    
    private func restartDebtAnimation() {
        stopDebtAnimation()
        startDebtAnimation()
    }
    
    private func formatAnimatedDebt(_ value: Double) -> String {
        let trillion = value / 1_000_000_000_000
        return String(format: "$%.6fT", trillion)
    }
}

// MARK: - Debt Detail Sheet
struct DebtDetailSheet: View {
    let debtData: DebtDataCollection
    let currentBtcPrice: Double
    @Environment(\.dismiss) private var dismiss
    
    @State private var animatedDebt: Double = 0
    @State private var timer: AnyCancellable?
    
    private var usDebt: USDebtData {
        debtData.usDebt ?? .placeholder
    }
    
    private var purchasingPower: DollarPurchasingPower {
        debtData.purchasingPower ?? .placeholder
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Section
                    debtHeroSection
                    
                    // Detailed Stats
                    debtBreakdownSection
                    
                    // Dollar Destruction Section
                    dollarDestructionSection
                    
                    // BTC as Solution
                    btcSolutionSection
                    
                    // Disclaimer
                    Text("Data from U.S. Treasury Fiscal Data. Dollar purchasing power calculated from CPI since 1913.")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
                .padding()
            }
            .background(AppColors.primaryBackground)
            .navigationTitle("US Debt & Dollar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.bitcoinOrange)
                }
            }
            .onAppear {
                startDebtAnimation()
            }
            .onDisappear {
                stopDebtAnimation()
            }
        }
    }
    
    // MARK: - Animation
    private func startDebtAnimation() {
        animatedDebt = usDebt.interpolatedDebt()
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                withAnimation(.linear(duration: 0.1)) {
                    animatedDebt = usDebt.interpolatedDebt()
                }
            }
    }
    
    private func stopDebtAnimation() {
        timer?.cancel()
        timer = nil
    }
    
    private func formatAnimatedDebt(_ value: Double) -> String {
        let trillion = value / 1_000_000_000_000
        return String(format: "$%.3fT", trillion)
    }
    
    // MARK: - Hero Section
    private var debtHeroSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.lossRed)
            
            Text("The Debt Clock")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text(formatAnimatedDebt(animatedDebt))
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(AppColors.lossRed)
                .contentTransition(.numericText())
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.lossRed)
                
                Text("Growing at $\(Int(usDebt.dailyIncreaseRate / 1_000_000_000))B per day")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Debt Breakdown
    private var debtBreakdownSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Debt Breakdown")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            
            // Debt held by public
            DebtStatRow(
                icon: "person.3.fill",
                iconColor: AppColors.lossRed,
                title: "Held by Public",
                value: usDebt.formattedDebtHeldByPublic,
                subtitle: "Bonds, notes, bills held by investors"
            )
            
            // Intragovernmental
            DebtStatRow(
                icon: "building.fill",
                iconColor: AppColors.neutralYellow,
                title: "Intragovernmental",
                value: formatLargeNumber(usDebt.intragovernmental),
                subtitle: "Owed to government trust funds"
            )
            
            // Per citizen
            DebtStatRow(
                icon: "person.fill",
                iconColor: AppColors.secondaryText,
                title: "Per US Citizen",
                value: usDebt.formattedDebtPerCitizen,
                subtitle: "Your share of the national debt"
            )
            
            // In BTC
            DebtStatRow(
                icon: "bitcoinsign.circle.fill",
                iconColor: AppColors.bitcoinOrange,
                title: "In BTC Terms",
                value: usDebt.formattedDebtInBTC(btcPrice: currentBtcPrice),
                subtitle: "At current BTC price"
            )
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Dollar Destruction
    private var dollarDestructionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Dollar Destruction Since 1913")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            
            // Visual representation
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: 20) {
                    // 1913 Dollar
                    VStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "85BB65"))
                        
                        Text("$1")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("in 1913")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    // Arrow
                    VStack {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.lossRed)
                        
                        Text("-\(purchasingPower.formattedPercentageLost)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.lossRed)
                    }
                    
                    // Today's value
                    VStack(spacing: 4) {
                        ZStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "85BB65").opacity(0.2))
                            
                            // Tiny remaining value visual
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: CGFloat(60 * purchasingPower.purchasingPowerRemaining)))
                                .foregroundColor(Color(hex: "85BB65"))
                        }
                        
                        Text(purchasingPower.formattedDollarValueToday)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.lossRed)
                        
                        Text("in 2026")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                Text("The Federal Reserve was created in 1913.\nSince then, the dollar has lost over 97% of its purchasing power.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - BTC Solution
    private var btcSolutionSection: some View {
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
                DebtBulletPoint(text: "Fixed supply: 21 million max, ever")
                DebtBulletPoint(text: "No central bank can print more")
                DebtBulletPoint(text: "Transparent monetary policy")
                DebtBulletPoint(text: "Self-custody: be your own bank")
            }
            
            // BTC vs Dollar comparison
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text("Dollar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("-\(purchasingPower.formattedPercentageLost)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.lossRed)
                    
                    Text("since 1913")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.lossRed.opacity(0.1))
                .cornerRadius(AppLayout.smallCornerRadius)
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Bitcoin")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("+∞")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.profitGreen)
                    
                    Text("since 2009")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.profitGreen.opacity(0.1))
                .cornerRadius(AppLayout.smallCornerRadius)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private func formatLargeNumber(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        }
        return String(format: "$%.0f", value)
    }
}

// MARK: - Helper Views
struct DebtStatRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.primaryText)
        }
        .padding(10)
        .background(AppColors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

struct DebtBulletPoint: View {
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

// MARK: - Compact Debt View (for inline use)
struct CompactDebtView: View {
    let debtData: DebtDataCollection
    
    private var usDebt: USDebtData {
        debtData.usDebt ?? .placeholder
    }
    
    private var purchasingPower: DollarPurchasingPower {
        debtData.purchasingPower ?? .placeholder
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Debt
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.lossRed)
                    
                    Text("US Debt")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                Text(usDebt.formattedTotalDebt)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.lossRed)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 30)
                .background(AppColors.tertiaryText.opacity(0.3))
            
            // Dollar Loss
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.neutralYellow)
                    
                    Text("$ Value")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                Text("-\(purchasingPower.formattedPercentageLost)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.lossRed)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            DebtCounterView(
                debtData: .placeholder,
                currentBtcPrice: 105000
            )
            
            CompactDebtView(debtData: .placeholder)
        }
        .padding()
    }
    .background(AppColors.primaryBackground)
}
