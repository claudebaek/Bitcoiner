//
//  ExchangeReserveView.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

struct ExchangeReserveView: View {
    let exchangeData: ExchangeData
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with total volume
            headerSection
            
            // Flow indicator
            flowIndicatorSection
            
            // Top exchanges list
            exchangeListSection
            
            // Premium data notice
            premiumDataNotice
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.bitcoinOrange)
                
                Text("Exchange Volume")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                Text(exchangeData.formattedTotalVolume)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("24h Volume")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.bottom, 4)
            }
        }
        .padding(AppLayout.padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    // MARK: - Flow Indicator Section
    private var flowIndicatorSection: some View {
        HStack(spacing: 12) {
            Image(systemName: exchangeData.flowDirection.icon)
                .font(.system(size: 32))
                .foregroundColor(Color(hex: exchangeData.flowDirection.colorHex))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exchangeData.flowDirection.description)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: exchangeData.flowDirection.colorHex))
                
                Text(flowDescription)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .padding(AppLayout.padding)
        .background(Color(hex: exchangeData.flowDirection.colorHex).opacity(0.1))
        .cornerRadius(AppLayout.cornerRadius)
    }
    
    private var flowDescription: String {
        switch exchangeData.flowDirection {
        case .inflow:
            return "Coins moving to exchanges (potentially bearish)"
        case .outflow:
            return "Coins leaving exchanges (potentially bullish)"
        case .neutral:
            return "Balanced flow between exchanges"
        }
    }
    
    // MARK: - Exchange List Section
    private var exchangeListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Exchanges by Volume")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("24h BTC Volume")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            if exchangeData.exchanges.isEmpty {
                emptyExchangeState
            } else {
                ForEach(Array(exchangeData.exchanges.prefix(5).enumerated()), id: \.element.id) { index, exchange in
                    ExchangeRowView(exchange: exchange, rank: index + 1)
                    
                    if index < min(4, exchangeData.exchanges.count - 1) {
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
    
    private var emptyExchangeState: some View {
        VStack(spacing: 8) {
            Image(systemName: "building.columns")
                .font(.system(size: 32))
                .foregroundColor(AppColors.tertiaryText)
            Text("No exchange data available")
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Premium Data Notice
    private var premiumDataNotice: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .foregroundColor(AppColors.neutralYellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Exchange Reserves")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Full on-chain reserve data requires CryptoQuant or Glassnode API")
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

// MARK: - Exchange Row View
struct ExchangeRowView: View {
    let exchange: Exchange
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(AppColors.tertiaryText)
                .frame(width: 20)
            
            // Exchange info
            VStack(alignment: .leading, spacing: 2) {
                Text(exchange.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                HStack(spacing: 4) {
                    TrustScoreBadge(score: exchange.trustScore)
                    
                    Text(exchange.country)
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            Spacer()
            
            // Volume
            Text(exchange.formattedVolume)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.bitcoinOrange)
        }
    }
}

// MARK: - Trust Score Badge
struct TrustScoreBadge: View {
    let score: Int
    
    private var color: Color {
        switch score {
        case 9...10:
            return AppColors.profitGreen
        case 7...8:
            return Color(hex: "81C784")
        case 5...6:
            return AppColors.neutralYellow
        default:
            return AppColors.lossRed
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 8))
            Text("\(score)")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.2))
        .cornerRadius(4)
    }
}

#Preview {
    ScrollView {
        ExchangeReserveView(exchangeData: ExchangeData(
            exchanges: [
                Exchange(id: "binance", name: "Binance", country: "Cayman Islands", trustScore: 10, volume24hBTC: 125000, volumeNormalized: 120000),
                Exchange(id: "coinbase", name: "Coinbase", country: "USA", trustScore: 10, volume24hBTC: 45000, volumeNormalized: 44000),
                Exchange(id: "kraken", name: "Kraken", country: "USA", trustScore: 10, volume24hBTC: 28000, volumeNormalized: 27000),
            ],
            totalVolume: 198000,
            volumeChange24h: -8.5,
            lastUpdated: Date()
        ))
        .padding()
    }
    .background(AppColors.primaryBackground)
}
