//
//  AssetComparison.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import Foundation
import SwiftUI

// MARK: - Asset Type
enum AssetType: String, CaseIterable, Identifiable {
    case bitcoin = "Bitcoin"
    case gold = "Gold"
    case nasdaq = "NASDAQ"
    case kospi = "KOSPI"
    case realEstate = "Real Estate"
    case dollarIndex = "Dollar Index"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .bitcoin: return "bitcoinsign.circle.fill"
        case .gold: return "sparkles"
        case .nasdaq: return "chart.line.uptrend.xyaxis"
        case .kospi: return "wonsign.circle.fill"
        case .realEstate: return "building.2.fill"
        case .dollarIndex: return "dollarsign.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bitcoin: return AppColors.bitcoinOrange
        case .gold: return Color(hex: "FFD700")
        case .nasdaq: return Color(hex: "00D4AA")  // Teal/Green
        case .kospi: return Color(hex: "E91E63")   // Pink/Red
        case .realEstate: return Color(hex: "4FC3F7")
        case .dollarIndex: return Color(hex: "85BB65")  // Dollar green
        }
    }
    
    var ticker: String {
        switch self {
        case .bitcoin: return "BTC"
        case .gold: return "Gold"
        case .nasdaq: return "NDX"
        case .kospi: return "KOSPI"
        case .realEstate: return "VNQ"
        case .dollarIndex: return "DXY"
        }
    }
}

// MARK: - Asset Comparison Data
struct AssetComparisonData: Identifiable {
    let id = UUID()
    let asset: AssetType
    let period: ComparisonPeriod
    let startPrice: Double
    let currentPrice: Double
    let unit: String
    
    var percentageReturn: Double {
        guard startPrice > 0 else { return 0 }
        return ((currentPrice - startPrice) / startPrice) * 100
    }
    
    var multiplier: Double {
        guard startPrice > 0 else { return 0 }
        return currentPrice / startPrice
    }
    
    var formattedReturn: String {
        let sign = percentageReturn >= 0 ? "+" : ""
        if abs(percentageReturn) >= 1000 {
            return String(format: "%@%.0f%%", sign, percentageReturn)
        }
        return String(format: "%@%.1f%%", sign, percentageReturn)
    }
    
    var formattedMultiplier: String {
        if multiplier >= 10 {
            return String(format: "%.0fx", multiplier)
        }
        return String(format: "%.1fx", multiplier)
    }
    
    var annualizedReturn: Double {
        guard startPrice > 0, period.years > 0 else { return 0 }
        let totalReturn = currentPrice / startPrice
        return (pow(totalReturn, 1.0 / period.years) - 1) * 100
    }
    
    var formattedAnnualizedReturn: String {
        let sign = annualizedReturn >= 0 ? "+" : ""
        return String(format: "%@%.1f%% p.a.", sign, annualizedReturn)
    }
}

// MARK: - Comparison Period
enum ComparisonPeriod: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case oneYear = "1Y"
    case fourYears = "4Y"
    case tenYears = "10Y"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .oneMonth: return "1 Month"
        case .oneYear: return "1 Year"
        case .fourYears: return "4 Years"
        case .tenYears: return "10 Years"
        }
    }
    
    var years: Double {
        switch self {
        case .oneMonth: return 1.0 / 12.0
        case .oneYear: return 1
        case .fourYears: return 4
        case .tenYears: return 10
        }
    }
    
    var months: Int {
        switch self {
        case .oneMonth: return 1
        case .oneYear: return 12
        case .fourYears: return 48
        case .tenYears: return 120
        }
    }
    
    var startDate: Date {
        Calendar.current.date(byAdding: .month, value: -months, to: Date()) ?? Date()
    }
}

// MARK: - Famous Real Estate
struct FamousRealEstate: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let purchaseYear: Int
    let purchasePrice: Double // in USD
    let currentPrice: Double // in USD
    let icon: String
    let description: String
    
    var yearsHeld: Int {
        Calendar.current.component(.year, from: Date()) - purchaseYear
    }
    
    var percentageReturn: Double {
        guard purchasePrice > 0 else { return 0 }
        return ((currentPrice - purchasePrice) / purchasePrice) * 100
    }
    
    var multiplier: Double {
        guard purchasePrice > 0 else { return 0 }
        return currentPrice / purchasePrice
    }
    
    var annualizedReturn: Double {
        guard purchasePrice > 0, yearsHeld > 0 else { return 0 }
        let totalReturn = currentPrice / purchasePrice
        return (pow(totalReturn, 1.0 / Double(yearsHeld)) - 1) * 100
    }
    
    var formattedPurchasePrice: String {
        if purchasePrice >= 1_000_000 {
            return String(format: "$%.1fM", purchasePrice / 1_000_000)
        }
        return String(format: "$%.0fK", purchasePrice / 1_000)
    }
    
    var formattedCurrentPrice: String {
        if currentPrice >= 1_000_000 {
            return String(format: "$%.1fM", currentPrice / 1_000_000)
        }
        return String(format: "$%.0fK", currentPrice / 1_000)
    }
    
    var formattedReturn: String {
        let sign = percentageReturn >= 0 ? "+" : ""
        return String(format: "%@%.0f%%", sign, percentageReturn)
    }
    
    var formattedMultiplier: String {
        String(format: "%.1fx", multiplier)
    }
    
    /// How much BTC you could have bought with the purchase price
    func btcAtPurchase(btcPriceAtPurchase: Double) -> Double {
        guard btcPriceAtPurchase > 0 else { return 0 }
        return purchasePrice / btcPriceAtPurchase
    }
    
    /// Value of that BTC today
    func btcValueToday(btcPriceAtPurchase: Double, currentBtcPrice: Double) -> Double {
        btcAtPurchase(btcPriceAtPurchase: btcPriceAtPurchase) * currentBtcPrice
    }
    
    /// How much more you'd have if you bought BTC instead
    func btcAdvantage(btcPriceAtPurchase: Double, currentBtcPrice: Double) -> Double {
        let btcValue = btcValueToday(btcPriceAtPurchase: btcPriceAtPurchase, currentBtcPrice: currentBtcPrice)
        return btcValue - currentPrice
    }
}

// MARK: - Famous Real Estate Collection
extension FamousRealEstate {
    /// Manhattan property for comparison
    static let manhattan = FamousRealEstate(
        name: "Manhattan Apartment",
        location: "New York, NY",
        purchaseYear: 2015,
        purchasePrice: 1_000_000,
        currentPrice: 1_500_000,
        icon: "building.2.fill",
        description: "Average Manhattan apartment"
    )
}

// MARK: - Historical Asset Prices
/// Historical prices for comparison (approximate data)
struct HistoricalAssetPrices {
    
    // MARK: - Gold Prices (per oz in USD)
    static let goldPrices: [Int: Double] = [
        2016: 1_150,
        2017: 1_260,
        2018: 1_280,
        2019: 1_390,
        2020: 1_770,
        2021: 1_820,
        2022: 1_800,
        2023: 1_940,
        2024: 2_050,
        2025: 2_680,
        2026: 2_750  // Current estimate
    ]
    
    // MARK: - Bitcoin Prices (approximate yearly averages/end)
    static let bitcoinPrices: [Int: Double] = [
        2014: 320,
        2015: 430,
        2016: 960,
        2017: 14_000,
        2018: 3_700,
        2019: 7_200,
        2020: 29_000,
        2021: 47_000,
        2022: 16_500,
        2023: 42_000,
        2024: 67_000,
        2025: 95_000,
        2026: 105_000  // Current estimate
    ]
    
    // MARK: - Manhattan Real Estate Index (normalized to 2015 = 100)
    // Based on median Manhattan apartment prices
    static let realEstateIndex: [Int: Double] = [
        2014: 95,
        2015: 100,
        2016: 103,
        2017: 105,
        2018: 107,
        2019: 104,  // NYC market cooled
        2020: 95,   // COVID impact
        2021: 105,
        2022: 115,
        2023: 125,
        2024: 140,
        2025: 150,
        2026: 155  // Current estimate
    ]
    
    // MARK: - NASDAQ Composite Index (approximate year-end values)
    static let nasdaqPrices: [Int: Double] = [
        2014: 4_736,
        2015: 5_007,
        2016: 5_383,
        2017: 6_903,
        2018: 6_635,
        2019: 8_972,
        2020: 12_888,
        2021: 15_644,
        2022: 10_466,
        2023: 15_011,
        2024: 17_500,
        2025: 19_200,
        2026: 20_000  // Current estimate
    ]
    
    // MARK: - KOSPI Index (approximate year-end values)
    static let kospiPrices: [Int: Double] = [
        2014: 1_916,
        2015: 1_961,
        2016: 2_026,
        2017: 2_467,
        2018: 2_041,
        2019: 2_197,
        2020: 2_873,
        2021: 2_977,
        2022: 2_236,
        2023: 2_655,
        2024: 2_850,
        2025: 2_650,
        2026: 2_700  // Current estimate
    ]
    
    // MARK: - US Dollar Index (DXY) - measures USD vs basket of currencies
    static let dollarIndexPrices: [Int: Double] = [
        2014: 88.0,
        2015: 98.5,
        2016: 102.0,
        2017: 92.0,
        2018: 96.0,
        2019: 96.5,
        2020: 89.5,
        2021: 96.0,
        2022: 103.5,
        2023: 101.0,
        2024: 104.0,
        2025: 108.0,
        2026: 109.0   // Current estimate
    ]
    
    // MARK: - VNQ (Vanguard Real Estate ETF) Prices
    static let vnqPrices: [Int: Double] = [
        2014: 78.0,
        2015: 75.0,
        2016: 81.0,
        2017: 82.0,
        2018: 74.0,
        2019: 93.0,
        2020: 81.0,   // COVID impact
        2021: 110.0,
        2022: 81.0,   // Interest rate hikes
        2023: 83.0,
        2024: 92.0,
        2025: 88.0,
        2026: 90.0   // Current estimate
    ]
    
    /// Get gold price for a specific year
    static func goldPrice(year: Int) -> Double {
        goldPrices[year] ?? goldPrices[2026] ?? 2750
    }
    
    /// Get bitcoin price for a specific year
    static func bitcoinPrice(year: Int) -> Double {
        bitcoinPrices[year] ?? bitcoinPrices[2026] ?? 105000
    }
    
    /// Get real estate index for a specific year
    static func realEstateIndex(year: Int) -> Double {
        realEstateIndex[year] ?? realEstateIndex[2026] ?? 155
    }
    
    /// Get NASDAQ price for a specific year
    static func nasdaqPrice(year: Int) -> Double {
        nasdaqPrices[year] ?? nasdaqPrices[2026] ?? 20000
    }
    
    /// Get KOSPI price for a specific year
    static func kospiPrice(year: Int) -> Double {
        kospiPrices[year] ?? kospiPrices[2026] ?? 2700
    }
    
    /// Get dollar index for a specific year
    static func dollarIndexPrice(year: Int) -> Double {
        dollarIndexPrices[year] ?? dollarIndexPrices[2026] ?? 109
    }
    
    /// Get VNQ price for a specific year
    static func vnqPrice(year: Int) -> Double {
        vnqPrices[year] ?? vnqPrices[2026] ?? 90
    }
    
    /// Get start year for a comparison period
    private static func startYear(for period: ComparisonPeriod) -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        switch period {
        case .oneMonth: return currentYear  // Use current year, will interpolate
        case .oneYear: return currentYear - 1
        case .fourYears: return currentYear - 4
        case .tenYears: return currentYear - 10
        }
    }
    
    /// Get price adjustment factor for 1-month lookback (estimate based on yearly change)
    private static func oneMonthFactor(currentPrice: Double, lastYearPrice: Double) -> Double {
        // Estimate 1-month price as: current - (yearly change / 12)
        let yearlyChange = currentPrice - lastYearPrice
        let monthlyChange = yearlyChange / 12.0
        return currentPrice - monthlyChange
    }
    
    /// Calculate gold returns for a period
    static func goldReturn(period: ComparisonPeriod, currentGoldPrice: Double? = nil) -> AssetComparisonData {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endPrice = currentGoldPrice ?? goldPrice(year: currentYear)
        let startPrice: Double
        
        if period == .oneMonth {
            startPrice = oneMonthFactor(currentPrice: endPrice, lastYearPrice: goldPrice(year: currentYear - 1))
        } else {
            startPrice = goldPrice(year: startYear(for: period))
        }
        
        return AssetComparisonData(
            asset: .gold,
            period: period,
            startPrice: startPrice,
            currentPrice: endPrice,
            unit: "/oz"
        )
    }
    
    /// Calculate real estate (VNQ ETF) returns for a period
    static func realEstateReturn(period: ComparisonPeriod) -> AssetComparisonData {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endPrice = vnqPrice(year: currentYear)
        let startPrice: Double
        
        if period == .oneMonth {
            startPrice = oneMonthFactor(currentPrice: endPrice, lastYearPrice: vnqPrice(year: currentYear - 1))
        } else {
            startPrice = vnqPrice(year: startYear(for: period))
        }
        
        return AssetComparisonData(
            asset: .realEstate,
            period: period,
            startPrice: startPrice,
            currentPrice: endPrice,
            unit: ""
        )
    }
    
    /// Calculate Bitcoin returns for a period
    static func bitcoinReturn(period: ComparisonPeriod, currentBtcPrice: Double? = nil, historicalPrice: Double? = nil) -> AssetComparisonData {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endPrice = currentBtcPrice ?? bitcoinPrice(year: currentYear)
        let startPrice: Double
        
        // Use real historical price if available, otherwise fall back to estimate
        if let realPrice = historicalPrice {
            startPrice = realPrice
        } else if period == .oneMonth {
            startPrice = oneMonthFactor(currentPrice: endPrice, lastYearPrice: bitcoinPrice(year: currentYear - 1))
        } else {
            startPrice = bitcoinPrice(year: startYear(for: period))
        }
        
        return AssetComparisonData(
            asset: .bitcoin,
            period: period,
            startPrice: startPrice,
            currentPrice: endPrice,
            unit: ""
        )
    }
    
    /// Calculate NASDAQ returns for a period
    static func nasdaqReturn(period: ComparisonPeriod) -> AssetComparisonData {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endPrice = nasdaqPrice(year: currentYear)
        let startPrice: Double
        
        if period == .oneMonth {
            startPrice = oneMonthFactor(currentPrice: endPrice, lastYearPrice: nasdaqPrice(year: currentYear - 1))
        } else {
            startPrice = nasdaqPrice(year: startYear(for: period))
        }
        
        return AssetComparisonData(
            asset: .nasdaq,
            period: period,
            startPrice: startPrice,
            currentPrice: endPrice,
            unit: ""
        )
    }
    
    /// Calculate KOSPI returns for a period
    static func kospiReturn(period: ComparisonPeriod) -> AssetComparisonData {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endPrice = kospiPrice(year: currentYear)
        let startPrice: Double
        
        if period == .oneMonth {
            startPrice = oneMonthFactor(currentPrice: endPrice, lastYearPrice: kospiPrice(year: currentYear - 1))
        } else {
            startPrice = kospiPrice(year: startYear(for: period))
        }
        
        return AssetComparisonData(
            asset: .kospi,
            period: period,
            startPrice: startPrice,
            currentPrice: endPrice,
            unit: ""
        )
    }
    
    /// Calculate Dollar Index (DXY) returns for a period
    static func dollarIndexReturn(period: ComparisonPeriod) -> AssetComparisonData {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endPrice = dollarIndexPrice(year: currentYear)
        let startPrice: Double
        
        if period == .oneMonth {
            startPrice = oneMonthFactor(currentPrice: endPrice, lastYearPrice: dollarIndexPrice(year: currentYear - 1))
        } else {
            startPrice = dollarIndexPrice(year: startYear(for: period))
        }
        
        return AssetComparisonData(
            asset: .dollarIndex,
            period: period,
            startPrice: startPrice,
            currentPrice: endPrice,
            unit: ""
        )
    }
}

// MARK: - Comparison Result
struct AssetComparisonResult: Identifiable {
    let id = UUID()
    let period: ComparisonPeriod
    let bitcoin: AssetComparisonData
    let gold: AssetComparisonData
    let nasdaq: AssetComparisonData
    let kospi: AssetComparisonData
    let realEstate: AssetComparisonData
    let dollarIndex: AssetComparisonData
    
    var allAssets: [AssetComparisonData] {
        [bitcoin, gold, nasdaq, kospi, realEstate, dollarIndex]
    }
    
    var winner: AssetType {
        let returns = [
            (AssetType.bitcoin, bitcoin.percentageReturn),
            (AssetType.gold, gold.percentageReturn),
            (AssetType.nasdaq, nasdaq.percentageReturn),
            (AssetType.kospi, kospi.percentageReturn),
            (AssetType.realEstate, realEstate.percentageReturn),
            (AssetType.dollarIndex, dollarIndex.percentageReturn)
        ]
        return returns.max(by: { $0.1 < $1.1 })?.0 ?? .bitcoin
    }
    
    var bitcoinVsGold: Double {
        bitcoin.percentageReturn - gold.percentageReturn
    }
    
    var bitcoinVsNasdaq: Double {
        bitcoin.percentageReturn - nasdaq.percentageReturn
    }
    
    var bitcoinVsKospi: Double {
        bitcoin.percentageReturn - kospi.percentageReturn
    }
    
    var bitcoinVsRealEstate: Double {
        bitcoin.percentageReturn - realEstate.percentageReturn
    }
    
    var bitcoinVsDollarIndex: Double {
        bitcoin.percentageReturn - dollarIndex.percentageReturn
    }
}

// MARK: - Asset Comparison Manager
class AssetComparisonManager {
    static let shared = AssetComparisonManager()
    
    private init() {}
    
    /// Generate comparison for all periods using real market data
    func generateComparisons(
        currentBtcPrice: Double,
        historicalBtcPrices: HistoricalPriceCollection = .placeholder,
        marketData: MarketDataCollection = .placeholder
    ) -> [AssetComparisonResult] {
        ComparisonPeriod.allCases.map { period in
            // Get real historical BTC price if available
            let historicalBtcPrice = getHistoricalBtcPrice(for: period, from: historicalBtcPrices)
            
            return AssetComparisonResult(
                period: period,
                bitcoin: HistoricalAssetPrices.bitcoinReturn(
                    period: period, 
                    currentBtcPrice: currentBtcPrice,
                    historicalPrice: historicalBtcPrice
                ),
                gold: goldReturn(period: period, marketData: marketData),
                nasdaq: nasdaqReturn(period: period, marketData: marketData),
                kospi: kospiReturn(period: period, marketData: marketData),
                realEstate: realEstateReturn(period: period, marketData: marketData),
                dollarIndex: dollarIndexReturn(period: period, marketData: marketData)
            )
        }
    }
    
    /// Map ComparisonPeriod to HistoricalPeriod and get real BTC price
    private func getHistoricalBtcPrice(for period: ComparisonPeriod, from collection: HistoricalPriceCollection) -> Double? {
        let historicalPeriod: HistoricalPeriod
        switch period {
        case .oneMonth: historicalPeriod = .oneMonth
        case .oneYear: historicalPeriod = .oneYear
        case .fourYears: historicalPeriod = .fourYears
        case .tenYears: historicalPeriod = .tenYears
        }
        return collection.prices[historicalPeriod]?.price
    }
    
    // MARK: - Real Market Data Returns
    
    /// Get Gold return using real API data or fallback to hardcoded
    private func goldReturn(period: ComparisonPeriod, marketData: MarketDataCollection) -> AssetComparisonData {
        if let gold = marketData.gold,
           let historicalPrice = gold.price(for: period) {
            return AssetComparisonData(
                asset: .gold,
                period: period,
                startPrice: historicalPrice,
                currentPrice: gold.currentPrice,
                unit: "/oz"
            )
        }
        // Fallback to hardcoded data
        return HistoricalAssetPrices.goldReturn(period: period)
    }
    
    /// Get NASDAQ return using real API data or fallback to hardcoded
    private func nasdaqReturn(period: ComparisonPeriod, marketData: MarketDataCollection) -> AssetComparisonData {
        if let nasdaq = marketData.nasdaq,
           let historicalPrice = nasdaq.price(for: period) {
            return AssetComparisonData(
                asset: .nasdaq,
                period: period,
                startPrice: historicalPrice,
                currentPrice: nasdaq.currentPrice,
                unit: ""
            )
        }
        // Fallback to hardcoded data
        return HistoricalAssetPrices.nasdaqReturn(period: period)
    }
    
    /// Get KOSPI return using real API data or fallback to hardcoded
    private func kospiReturn(period: ComparisonPeriod, marketData: MarketDataCollection) -> AssetComparisonData {
        if let kospi = marketData.kospi,
           let historicalPrice = kospi.price(for: period) {
            return AssetComparisonData(
                asset: .kospi,
                period: period,
                startPrice: historicalPrice,
                currentPrice: kospi.currentPrice,
                unit: ""
            )
        }
        // Fallback to hardcoded data
        return HistoricalAssetPrices.kospiReturn(period: period)
    }
    
    /// Get Real Estate (VNQ ETF) return using real API data or fallback to hardcoded
    private func realEstateReturn(period: ComparisonPeriod, marketData: MarketDataCollection) -> AssetComparisonData {
        if let realEstate = marketData.realEstate,
           let historicalPrice = realEstate.price(for: period) {
            return AssetComparisonData(
                asset: .realEstate,
                period: period,
                startPrice: historicalPrice,
                currentPrice: realEstate.currentPrice,
                unit: ""
            )
        }
        // Fallback to hardcoded data
        return HistoricalAssetPrices.realEstateReturn(period: period)
    }
    
    /// Get Dollar Index (DXY) return using real API data or fallback to hardcoded
    private func dollarIndexReturn(period: ComparisonPeriod, marketData: MarketDataCollection) -> AssetComparisonData {
        if let dollarIndex = marketData.dollarIndex,
           let historicalPrice = dollarIndex.price(for: period) {
            return AssetComparisonData(
                asset: .dollarIndex,
                period: period,
                startPrice: historicalPrice,
                currentPrice: dollarIndex.currentPrice,
                unit: ""
            )
        }
        // Fallback to hardcoded data
        return HistoricalAssetPrices.dollarIndexReturn(period: period)
    }
    
    /// Generate real estate comparison for a specific property
    func comparePropertyToBitcoin(property: FamousRealEstate, currentBtcPrice: Double) -> (btcReturn: Double, propertyReturn: Double, btcAdvantage: Double) {
        let btcPriceAtPurchase = HistoricalAssetPrices.bitcoinPrice(year: property.purchaseYear)
        let btcValue = property.btcValueToday(btcPriceAtPurchase: btcPriceAtPurchase, currentBtcPrice: currentBtcPrice)
        let btcReturn = ((btcValue - property.purchasePrice) / property.purchasePrice) * 100
        let advantage = property.btcAdvantage(btcPriceAtPurchase: btcPriceAtPurchase, currentBtcPrice: currentBtcPrice)
        
        return (btcReturn, property.percentageReturn, advantage)
    }
}
