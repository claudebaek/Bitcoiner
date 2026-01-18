//
//  ExchangeData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation

// MARK: - CoinGecko Exchange Response
struct ExchangeResponse: Codable {
    let id: String
    let name: String
    let yearEstablished: Int?
    let country: String?
    let trustScore: Int?
    let trustScoreRank: Int?
    let tradeVolume24hBtc: Double?
    let tradeVolume24hBtcNormalized: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case yearEstablished = "year_established"
        case country
        case trustScore = "trust_score"
        case trustScoreRank = "trust_score_rank"
        case tradeVolume24hBtc = "trade_volume_24h_btc"
        case tradeVolume24hBtcNormalized = "trade_volume_24h_btc_normalized"
    }
}

// MARK: - App Models
struct ExchangeData: Identifiable {
    let id = UUID()
    let exchanges: [Exchange]
    let totalVolume: Double
    let volumeChange24h: Double
    let lastUpdated: Date
    
    var formattedTotalVolume: String {
        formatBTCVolume(totalVolume)
    }
    
    var flowDirection: FlowDirection {
        if volumeChange24h > 5 {
            return .inflow
        } else if volumeChange24h < -5 {
            return .outflow
        } else {
            return .neutral
        }
    }
    
    private func formatBTCVolume(_ btc: Double) -> String {
        if btc >= 1_000_000 {
            return String(format: "%.2fM BTC", btc / 1_000_000)
        } else if btc >= 1_000 {
            return String(format: "%.2fK BTC", btc / 1_000)
        } else {
            return String(format: "%.2f BTC", btc)
        }
    }
    
    static var placeholder: ExchangeData {
        ExchangeData(
            exchanges: [],
            totalVolume: 0,
            volumeChange24h: 0,
            lastUpdated: Date()
        )
    }
}

struct Exchange: Identifiable {
    let id: String
    let name: String
    let country: String
    let trustScore: Int
    let volume24hBTC: Double
    let volumeNormalized: Double
    
    var formattedVolume: String {
        if volume24hBTC >= 1_000 {
            return String(format: "%.1fK BTC", volume24hBTC / 1_000)
        } else {
            return String(format: "%.2f BTC", volume24hBTC)
        }
    }
    
    var trustScoreColor: String {
        switch trustScore {
        case 9...10:
            return "00C853"
        case 7...8:
            return "81C784"
        case 5...6:
            return "FFD54F"
        default:
            return "FF5252"
        }
    }
}

enum FlowDirection {
    case inflow
    case outflow
    case neutral
    
    var description: String {
        switch self {
        case .inflow:
            return "Net Inflow"
        case .outflow:
            return "Net Outflow"
        case .neutral:
            return "Neutral"
        }
    }
    
    var icon: String {
        switch self {
        case .inflow:
            return "arrow.down.circle.fill"
        case .outflow:
            return "arrow.up.circle.fill"
        case .neutral:
            return "equal.circle.fill"
        }
    }
    
    var colorHex: String {
        switch self {
        case .inflow:
            return "FF5252" // Red - bearish (coins moving to exchange)
        case .outflow:
            return "00C853" // Green - bullish (coins leaving exchange)
        case .neutral:
            return "FFD54F"
        }
    }
}

// MARK: - Reserve Placeholder (Premium Data)
struct ExchangeReserve: Identifiable {
    let id = UUID()
    let exchangeName: String
    let reserveBTC: Double
    let reserveChange24h: Double
    let isPremiumData: Bool
    
    static var placeholders: [ExchangeReserve] {
        [
            ExchangeReserve(exchangeName: "Binance", reserveBTC: 0, reserveChange24h: 0, isPremiumData: true),
            ExchangeReserve(exchangeName: "Coinbase", reserveBTC: 0, reserveChange24h: 0, isPremiumData: true),
            ExchangeReserve(exchangeName: "Kraken", reserveBTC: 0, reserveChange24h: 0, isPremiumData: true),
            ExchangeReserve(exchangeName: "OKX", reserveBTC: 0, reserveChange24h: 0, isPremiumData: true),
        ]
    }
}
