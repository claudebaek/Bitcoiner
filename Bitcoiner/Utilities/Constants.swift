//
//  Constants.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

enum AppConstants {
    // MARK: - API Endpoints
    enum API {
        static let coinGeckoBase = "https://api.coingecko.com/api/v3"
        static let fearGreedBase = "https://api.alternative.me/fng"
        static let binanceFuturesBase = "https://fapi.binance.com/futures/data"
        
        // CoinGecko Endpoints
        static let bitcoinPrice = "\(coinGeckoBase)/simple/price?ids=bitcoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true"
        static let bitcoinDetail = "\(coinGeckoBase)/coins/bitcoin?localization=false&tickers=false&community_data=false&developer_data=false"
        static let exchanges = "\(coinGeckoBase)/exchanges?per_page=10"
        
        /// Historical price at a specific date (dd-mm-yyyy format)
        static func bitcoinHistory(date: String) -> String {
            "\(coinGeckoBase)/coins/bitcoin/history?date=\(date)&localization=false"
        }
        
        // Fear & Greed Endpoints
        static let fearGreedCurrent = "\(fearGreedBase)/?limit=1"
        static let fearGreedHistory = "\(fearGreedBase)/?limit=7"
        
        // Binance Futures Endpoints
        static func longShortRatio(symbol: String = "BTCUSDT", period: String = "5m", limit: Int = 30) -> String {
            "\(binanceFuturesBase)/globalLongShortAccountRatio?symbol=\(symbol)&period=\(period)&limit=\(limit)"
        }
        
        static func topTraderLongShortRatio(symbol: String = "BTCUSDT", period: String = "5m", limit: Int = 30) -> String {
            "\(binanceFuturesBase)/topLongShortAccountRatio?symbol=\(symbol)&period=\(period)&limit=\(limit)"
        }
        
        static func topTraderPositionRatio(symbol: String = "BTCUSDT", period: String = "5m", limit: Int = 30) -> String {
            "\(binanceFuturesBase)/topLongShortPositionRatio?symbol=\(symbol)&period=\(period)&limit=\(limit)"
        }
        
        // Mempool.space Endpoints (Mining Data)
        static let mempoolBase = "https://mempool.space/api/v1"
        static let mempoolDifficultyAdjustment = "\(mempoolBase)/difficulty-adjustment"
        static let mempoolHashrate = "\(mempoolBase)/mining/hashrate/1m"
        static let mempoolHashrate3d = "\(mempoolBase)/mining/hashrate/3d"
        static let mempoolBlocks = "\(mempoolBase)/blocks"
    }
    
    // MARK: - Refresh Intervals (in seconds)
    enum RefreshInterval {
        static let price: TimeInterval = 30
        static let fearGreed: TimeInterval = 300 // 5 minutes
        static let positions: TimeInterval = 60
        static let exchanges: TimeInterval = 300
    }
    
    // MARK: - Cache Duration (in seconds)
    enum CacheDuration {
        static let price: TimeInterval = 15
        static let fearGreed: TimeInterval = 300
        static let positions: TimeInterval = 30
        static let mining: TimeInterval = 300  // 5 minutes - network data doesn't change fast
    }
}

// MARK: - User Defaults Keys
enum UserDefaultsKeys {
    static let miningSettings = "miningSettings"
}

// MARK: - Theme Colors
enum AppColors {
    // Backgrounds
    static let primaryBackground = Color(hex: "0D0D0D")
    static let cardBackground = Color(hex: "1A1A1A")
    static let secondaryBackground = Color(hex: "252525")
    
    // Accent Colors
    static let bitcoinOrange = Color(hex: "F7931A")
    static let profitGreen = Color(hex: "00C853")
    static let lossRed = Color(hex: "FF5252")
    static let neutralYellow = Color(hex: "FFD54F")
    
    // Text Colors
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "9E9E9E")
    static let tertiaryText = Color(hex: "616161")
    
    // Fear & Greed Gradient
    static let fearGreedGradient = [
        Color(hex: "FF5252"), // Extreme Fear
        Color(hex: "FF8A65"), // Fear
        Color(hex: "FFD54F"), // Neutral
        Color(hex: "81C784"), // Greed
        Color(hex: "00C853")  // Extreme Greed
    ]
    
    // Chart Colors
    static let longColor = Color(hex: "00C853")
    static let shortColor = Color(hex: "FF5252")
    static let chartLine = Color(hex: "F7931A")
    static let chartFill = Color(hex: "F7931A").opacity(0.2)
}

// MARK: - Layout Constants
enum AppLayout {
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let cardSpacing: CGFloat = 12
    static let iconSize: CGFloat = 24
    static let largeIconSize: CGFloat = 48
}
