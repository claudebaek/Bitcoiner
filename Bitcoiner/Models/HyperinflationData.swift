//
//  HyperinflationData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import Foundation
import SwiftUI

// MARK: - Inflation Category
enum InflationCategory: String, CaseIterable {
    case historical = "Historical"
    case current = "Current"
}

// MARK: - Inflation Severity Tier
enum InflationTier: String {
    case crisis = "Crisis"      // >100%
    case severe = "Severe"      // 50-100%
    case high = "High"          // 20-50%
    case historical = "Historical"
    
    var color: Color {
        switch self {
        case .crisis:
            return Color.red
        case .severe:
            return Color.orange
        case .high:
            return Color.yellow
        case .historical:
            return Color.gray
        }
    }
}

// MARK: - Hyperinflation Case
struct HyperinflationCase: Identifiable {
    let id = UUID()
    let country: String
    let countryCode: String     // ISO country code for flag
    let flagEmoji: String
    let currency: String
    let year: String            // "2024" or "1946" or "2018-present"
    let peakInflation: String   // Formatted string like "190%+" or "4.19×10¹⁶%"
    let inflationValue: Double  // For sorting (use approximate value)
    let category: InflationCategory
    let tier: InflationTier
    let description: String
    
    // MARK: - Historical Cases
    static let historicalCases: [HyperinflationCase] = [
        HyperinflationCase(
            country: "Hungary",
            countryCode: "HU",
            flagEmoji: "🇭🇺",
            currency: "Pengő",
            year: "1946",
            peakInflation: "4.19×10¹⁶%",
            inflationValue: 4.19e16,
            category: .historical,
            tier: .historical,
            description: "The worst hyperinflation in recorded history. Prices doubled every 15 hours."
        ),
        HyperinflationCase(
            country: "Zimbabwe",
            countryCode: "ZW",
            flagEmoji: "🇿🇼",
            currency: "Zimbabwean Dollar",
            year: "2008",
            peakInflation: "79.6B%",
            inflationValue: 79_600_000_000,
            category: .historical,
            tier: .historical,
            description: "Peak monthly inflation of 79.6 billion percent. 100 trillion dollar notes were printed."
        ),
        HyperinflationCase(
            country: "Yugoslavia",
            countryCode: "YU",
            flagEmoji: "🇷🇸",
            currency: "Yugoslav Dinar",
            year: "1994",
            peakInflation: "313M%",
            inflationValue: 313_000_000,
            category: .historical,
            tier: .historical,
            description: "Monthly inflation reached 313 million percent during the Yugoslav Wars."
        ),
        HyperinflationCase(
            country: "Germany",
            countryCode: "DE",
            flagEmoji: "🇩🇪",
            currency: "Papiermark",
            year: "1923",
            peakInflation: "29,500%",
            inflationValue: 29_500,
            category: .historical,
            tier: .historical,
            description: "Weimar Republic hyperinflation. Workers were paid twice daily to spend before prices rose."
        ),
        HyperinflationCase(
            country: "Venezuela",
            countryCode: "VE",
            flagEmoji: "🇻🇪",
            currency: "Bolívar",
            year: "2018",
            peakInflation: "1.7M%",
            inflationValue: 1_700_000,
            category: .historical,
            tier: .historical,
            description: "Peak annual inflation exceeded 1.7 million percent in 2018."
        )
    ]
    
    // MARK: - Current High Inflation Cases
    static let currentCases: [HyperinflationCase] = [
        // Tier 1 - Crisis Level (>100%)
        HyperinflationCase(
            country: "Venezuela",
            countryCode: "VE",
            flagEmoji: "🇻🇪",
            currency: "Bolívar",
            year: "2024",
            peakInflation: "190%+",
            inflationValue: 190,
            category: .current,
            tier: .crisis,
            description: "Chronic economic crisis continues with triple-digit inflation."
        ),
        HyperinflationCase(
            country: "Lebanon",
            countryCode: "LB",
            flagEmoji: "🇱🇧",
            currency: "Lebanese Pound",
            year: "2024",
            peakInflation: "150%+",
            inflationValue: 150,
            category: .current,
            tier: .crisis,
            description: "Economic collapse with currency losing 98% of value since 2019."
        ),
        HyperinflationCase(
            country: "Argentina",
            countryCode: "AR",
            flagEmoji: "🇦🇷",
            currency: "Argentine Peso",
            year: "2024",
            peakInflation: "140%",
            inflationValue: 140,
            category: .current,
            tier: .crisis,
            description: "Persistent inflation despite multiple currency reforms."
        ),
        HyperinflationCase(
            country: "Syria",
            countryCode: "SY",
            flagEmoji: "🇸🇾",
            currency: "Syrian Pound",
            year: "2024",
            peakInflation: "100%+",
            inflationValue: 100,
            category: .current,
            tier: .crisis,
            description: "War and sanctions have devastated the economy."
        ),
        
        // Tier 2 - Severe (50-100%)
        HyperinflationCase(
            country: "Sudan",
            countryCode: "SD",
            flagEmoji: "🇸🇩",
            currency: "Sudanese Pound",
            year: "2024",
            peakInflation: "90%+",
            inflationValue: 90,
            category: .current,
            tier: .severe,
            description: "Civil war causing economic devastation."
        ),
        HyperinflationCase(
            country: "Turkey",
            countryCode: "TR",
            flagEmoji: "🇹🇷",
            currency: "Turkish Lira",
            year: "2024",
            peakInflation: "65%",
            inflationValue: 65,
            category: .current,
            tier: .severe,
            description: "Unorthodox monetary policy has weakened the lira."
        ),
        
        // Tier 3 - High (20-50%)
        HyperinflationCase(
            country: "Iran",
            countryCode: "IR",
            flagEmoji: "🇮🇷",
            currency: "Iranian Rial",
            year: "2024",
            peakInflation: "45%",
            inflationValue: 45,
            category: .current,
            tier: .high,
            description: "International sanctions impact on economy."
        ),
        HyperinflationCase(
            country: "Egypt",
            countryCode: "EG",
            flagEmoji: "🇪🇬",
            currency: "Egyptian Pound",
            year: "2024",
            peakInflation: "35%",
            inflationValue: 35,
            category: .current,
            tier: .high,
            description: "Currency crisis and devaluation."
        ),
        HyperinflationCase(
            country: "Pakistan",
            countryCode: "PK",
            flagEmoji: "🇵🇰",
            currency: "Pakistani Rupee",
            year: "2024",
            peakInflation: "30%",
            inflationValue: 30,
            category: .current,
            tier: .high,
            description: "Economic instability and IMF bailout conditions."
        ),
        HyperinflationCase(
            country: "Nigeria",
            countryCode: "NG",
            flagEmoji: "🇳🇬",
            currency: "Nigerian Naira",
            year: "2024",
            peakInflation: "30%",
            inflationValue: 30,
            category: .current,
            tier: .high,
            description: "Currency devaluation and subsidy removal."
        ),
        HyperinflationCase(
            country: "Sierra Leone",
            countryCode: "SL",
            flagEmoji: "🇸🇱",
            currency: "Sierra Leonean Leone",
            year: "2024",
            peakInflation: "30%+",
            inflationValue: 30,
            category: .current,
            tier: .high,
            description: "Economic challenges and currency weakness."
        ),
        HyperinflationCase(
            country: "Haiti",
            countryCode: "HT",
            flagEmoji: "🇭🇹",
            currency: "Haitian Gourde",
            year: "2024",
            peakInflation: "25%+",
            inflationValue: 25,
            category: .current,
            tier: .high,
            description: "Political instability and gang violence."
        ),
        HyperinflationCase(
            country: "Ethiopia",
            countryCode: "ET",
            flagEmoji: "🇪🇹",
            currency: "Ethiopian Birr",
            year: "2024",
            peakInflation: "25%",
            inflationValue: 25,
            category: .current,
            tier: .high,
            description: "Post-conflict economic recovery challenges."
        ),
        HyperinflationCase(
            country: "Ghana",
            countryCode: "GH",
            flagEmoji: "🇬🇭",
            currency: "Ghanaian Cedi",
            year: "2024",
            peakInflation: "25%",
            inflationValue: 25,
            category: .current,
            tier: .high,
            description: "Debt crisis and currency depreciation."
        ),
        HyperinflationCase(
            country: "Malawi",
            countryCode: "MW",
            flagEmoji: "🇲🇼",
            currency: "Malawian Kwacha",
            year: "2024",
            peakInflation: "25%",
            inflationValue: 25,
            category: .current,
            tier: .high,
            description: "Currency devaluation and food price increases."
        ),
        HyperinflationCase(
            country: "Myanmar",
            countryCode: "MM",
            flagEmoji: "🇲🇲",
            currency: "Myanmar Kyat",
            year: "2024",
            peakInflation: "20%+",
            inflationValue: 20,
            category: .current,
            tier: .high,
            description: "Post-coup economic collapse."
        ),
        HyperinflationCase(
            country: "Zimbabwe",
            countryCode: "ZW",
            flagEmoji: "🇿🇼",
            currency: "ZiG (Zimbabwe Gold)",
            year: "2024",
            peakInflation: "20%+",
            inflationValue: 20,
            category: .current,
            tier: .high,
            description: "New gold-backed currency launched amid recurring inflation."
        )
    ]
    
    // MARK: - All Cases
    static var allCases: [HyperinflationCase] {
        historicalCases + currentCases
    }
    
    // MARK: - Grouped by Tier
    static var currentByTier: [InflationTier: [HyperinflationCase]] {
        Dictionary(grouping: currentCases, by: { $0.tier })
    }
}

// MARK: - Hyperinflation Statistics
struct HyperinflationStats {
    static var totalCountries: Int {
        HyperinflationCase.currentCases.count
    }
    
    static var crisisCount: Int {
        HyperinflationCase.currentCases.filter { $0.tier == .crisis }.count
    }
    
    static var severeCount: Int {
        HyperinflationCase.currentCases.filter { $0.tier == .severe }.count
    }
    
    static var highCount: Int {
        HyperinflationCase.currentCases.filter { $0.tier == .high }.count
    }
    
    static var historicalCount: Int {
        HyperinflationCase.historicalCases.count
    }
}
