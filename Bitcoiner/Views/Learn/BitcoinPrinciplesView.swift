//
//  BitcoinPrinciplesView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import SwiftUI

struct BitcoinPrinciplesView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var animateNetwork = false
    @State private var animateBlocks = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Core Principle: Decentralization
                decentralizationDiagram
                
                // Blockchain Structure
                blockchainDiagram
                
                // Mining / Proof of Work
                miningDiagram
                
                // Limited Supply
                supplyDiagram
                
                // Transaction Flow
                transactionDiagram
                
                // Key Features Summary
                featuresSummary
                
                // Quote
                quoteSection
            }
            .padding()
        }
        .background(AppColors.primaryBackground)
        .navigationTitle(L10n.bpNavTitle)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateNetwork = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateBlocks = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.bitcoinOrange, AppColors.bitcoinOrange.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColors.bitcoinOrange.opacity(0.5), radius: 20)
            
            Text(L10n.bpHeaderTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text(L10n.bpHeaderSubtitle)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Decentralization Diagram
    private var decentralizationDiagram: some View {
        VStack(spacing: 16) {
            sectionTitle(L10n.bpSectionDecentralized, icon: "network", color: AppColors.bitcoinOrange)
            
            ZStack {
                // Connection lines
                ForEach(0..<6, id: \.self) { i in
                    ForEach((i+1)..<6, id: \.self) { j in
                        ConnectionLine(
                            from: nodePosition(index: i, count: 6),
                            to: nodePosition(index: j, count: 6)
                        )
                    }
                }
                
                // Nodes
                ForEach(0..<6, id: \.self) { index in
                    NetworkNode(isAnimating: animateNetwork)
                        .position(nodePosition(index: index, count: 6))
                }
                
                // Center Bitcoin
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.bitcoinOrange)
                    .scaleEffect(animateNetwork ? 1.1 : 1.0)
            }
            .frame(height: 200)
            .background(AppColors.cardBackground.opacity(0.5))
            .cornerRadius(AppLayout.cornerRadius)
            
            Text(L10n.bpDecentralizedDesc)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Blockchain Diagram
    private var blockchainDiagram: some View {
        VStack(spacing: 16) {
            sectionTitle(L10n.bpSectionBlockchain, icon: "cube.fill", color: AppColors.profitGreen)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        BlockView(
                            blockNumber: 800000 + index,
                            blockLabel: L10n.bpBlock,
                            isAnimating: animateBlocks,
                            delay: Double(index) * 0.2
                        )
                        
                        if index < 4 {
                            Image(systemName: "link")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.tertiaryText)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 120)
            
            // Hash chain explanation
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    BlockDetail(label: "Hash", value: "000...abc", color: AppColors.bitcoinOrange)
                    BlockDetail(label: L10n.bpPrevHash, value: "000...xyz", color: AppColors.profitGreen)
                    BlockDetail(label: "Nonce", value: "2,891,047", color: AppColors.neutralYellow)
                }
            }
            .padding()
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppLayout.smallCornerRadius)
            
            Text(L10n.bpBlockchainDesc)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Mining Diagram
    private var miningDiagram: some View {
        VStack(spacing: 16) {
            sectionTitle(L10n.bpSectionMining, icon: "hammer.fill", color: AppColors.neutralYellow)
            
            HStack(spacing: 20) {
                // Miners
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.secondaryBackground)
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.neutralYellow)
                    }
                    Text(L10n.bpMiners)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                // Arrow
                VStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.tertiaryText)
                    Text(L10n.bpSolvePuzzle)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                
                // Block creation
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.profitGreen.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "cube.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.profitGreen)
                    }
                    Text(L10n.bpNewBlock)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                // Arrow
                VStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.tertiaryText)
                    Text(L10n.bpEarn)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                // Reward
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.bitcoinOrange.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "bitcoinsign")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.bitcoinOrange)
                            Text("3.125")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.bitcoinOrange)
                        }
                    }
                    Text(L10n.bpReward)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .padding()
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppLayout.cornerRadius)
            
            // Difficulty stats
            HStack(spacing: 16) {
                MiningStatView(label: L10n.bpBlockTime, value: L10n.bpBlockTimeValue, icon: "clock.fill")
                MiningStatView(label: L10n.bpDifficulty, value: L10n.bpDifficultyValue, icon: "dial.high.fill")
                MiningStatView(label: L10n.bpHalving, value: L10n.bpHalvingValue, icon: "arrow.down.circle.fill")
            }
            
            Text(L10n.bpMiningDesc)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Supply Diagram
    private var supplyDiagram: some View {
        VStack(spacing: 16) {
            sectionTitle(L10n.bpSectionSupply, icon: "chart.bar.fill", color: AppColors.lossRed)
            
            // Visual supply bar
            VStack(spacing: 12) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background (total supply)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.secondaryBackground)
                        
                        // Mined supply (~19.6M / 21M ≈ 93%)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.bitcoinOrange, AppColors.neutralYellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * 0.93)
                        
                        // Labels
                        HStack {
                            Text(L10n.bpMined)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.leading, 12)
                            
                            Spacer()
                            
                            Text(L10n.bpLeft)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.tertiaryText)
                                .padding(.trailing, 8)
                        }
                    }
                }
                .frame(height: 40)
                
                HStack {
                    Text("0")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                    Spacer()
                    Text(L10n.bpMaxSupply)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            .padding()
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppLayout.cornerRadius)
            
            // Halving timeline
            VStack(spacing: 8) {
                Text(L10n.bpHalvingSchedule)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                HStack(spacing: 4) {
                    HalvingEvent(year: "2009", reward: "50 BTC", isPast: true)
                    HalvingEvent(year: "2012", reward: "25 BTC", isPast: true)
                    HalvingEvent(year: "2016", reward: "12.5 BTC", isPast: true)
                    HalvingEvent(year: "2020", reward: "6.25 BTC", isPast: true)
                    HalvingEvent(year: "2024", reward: "3.125 BTC", isPast: true)
                    HalvingEvent(year: "2028", reward: "1.5625 BTC", isPast: false)
                }
            }
            .padding()
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppLayout.cornerRadius)
            
            Text(L10n.bpSupplyDesc)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Transaction Diagram
    private var transactionDiagram: some View {
        VStack(spacing: 16) {
            sectionTitle(L10n.bpSectionP2p, icon: "arrow.left.arrow.right", color: AppColors.profitGreen)
            
            HStack(spacing: 12) {
                // Sender
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(AppColors.profitGreen.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.profitGreen)
                    }
                    Text(L10n.bpSender)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                // Transaction flow
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(AppColors.bitcoinOrange)
                                .frame(width: 6, height: 6)
                        }
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.bitcoinOrange)
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(AppColors.bitcoinOrange)
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    VStack(spacing: 2) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.neutralYellow)
                        Text(L10n.bpSignedVerified)
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
                
                // Receiver
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(AppColors.profitGreen.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.profitGreen)
                    }
                    Text(L10n.bpReceiver)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .padding()
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppLayout.cornerRadius)
            
            // Key pair explanation
            HStack(spacing: 16) {
                KeyView(type: L10n.bpPrivateKey, icon: "key.fill", color: AppColors.lossRed, description: L10n.bpSecretNeverShare)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(AppColors.tertiaryText)
                
                KeyView(type: L10n.bpPublicKey, icon: "key.horizontal.fill", color: AppColors.profitGreen, description: L10n.bpYourAddress)
            }
            .padding()
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppLayout.cornerRadius)
            
            Text(L10n.bpP2pDesc)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Features Summary
    private var featuresSummary: some View {
        VStack(spacing: 16) {
            Text(L10n.bpKeyProperties)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                FeatureCard(icon: "shield.checkered", title: L10n.bpSecure, description: L10n.bpSecureDesc, color: AppColors.profitGreen)
                FeatureCard(icon: "globe", title: L10n.bpBorderless, description: L10n.bpBorderlessDesc, color: AppColors.bitcoinOrange)
                FeatureCard(icon: "eye.slash", title: L10n.bpPseudonymous, description: L10n.bpPseudonymousDesc, color: AppColors.neutralYellow)
                FeatureCard(icon: "clock.arrow.circlepath", title: L10n.bpIrreversible, description: L10n.bpIrreversibleDesc, color: AppColors.lossRed)
                FeatureCard(icon: "checkmark.seal", title: L10n.bpVerifiable, description: L10n.bpVerifiableDesc, color: AppColors.profitGreen)
                FeatureCard(icon: "infinity", title: L10n.bpImmutable, description: L10n.bpImmutableDesc, color: AppColors.bitcoinOrange)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Quote Section
    private var quoteSection: some View {
        VStack(spacing: 12) {
            Text(L10n.bpQuote)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)
                .italic()
            
            Text(L10n.bpQuoteAuthor)
                .font(.system(size: 12))
                .foregroundColor(AppColors.bitcoinOrange)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Helper Functions
    private func sectionTitle(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
        }
    }
    
    private func nodePosition(index: Int, count: Int) -> CGPoint {
        let radius: CGFloat = 80
        let centerX: CGFloat = 175
        let centerY: CGFloat = 100
        let angle = (2 * .pi / CGFloat(count)) * CGFloat(index) - .pi / 2
        
        return CGPoint(
            x: centerX + radius * cos(angle),
            y: centerY + radius * sin(angle)
        )
    }
}

// MARK: - Supporting Views

struct NetworkNode: View {
    var isAnimating: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.profitGreen.opacity(0.3))
                .frame(width: 32, height: 32)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
            
            Image(systemName: "desktopcomputer")
                .font(.system(size: 14))
                .foregroundColor(AppColors.profitGreen)
        }
    }
}

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    
    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(AppColors.tertiaryText.opacity(0.3), lineWidth: 1)
    }
}

struct BlockView: View {
    let blockNumber: Int
    let blockLabel: String
    let isAnimating: Bool
    let delay: Double
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [AppColors.profitGreen.opacity(0.3), AppColors.profitGreen.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.profitGreen)
                        Text("#\(blockNumber)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppColors.secondaryText)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.profitGreen.opacity(0.5), lineWidth: 1)
                )
            
            Text(blockLabel)
                .font(.system(size: 10))
                .foregroundColor(AppColors.tertiaryText)
        }
    }
}

struct BlockDetail: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.tertiaryText)
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

struct MiningStatView: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.neutralYellow)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

struct HalvingEvent: View {
    let year: String
    let reward: String
    let isPast: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isPast ? AppColors.bitcoinOrange : AppColors.tertiaryText)
                .frame(width: 12, height: 12)
            Text(year)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(isPast ? AppColors.primaryText : AppColors.tertiaryText)
            Text(reward)
                .font(.system(size: 7))
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct KeyView: View {
    let type: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(type)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            Text(description)
                .font(.system(size: 9))
                .foregroundColor(AppColors.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppLayout.smallCornerRadius)
    }
}

#Preview {
    NavigationStack {
        BitcoinPrinciplesView()
    }
    .preferredColorScheme(.dark)
}
