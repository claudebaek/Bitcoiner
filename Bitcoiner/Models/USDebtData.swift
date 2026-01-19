//
//  USDebtData.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import Foundation
import SwiftUI

// MARK: - US Debt Data
struct USDebtData: Identifiable {
    let id = UUID()
    let totalDebt: Double           // Total public debt outstanding
    let debtHeldByPublic: Double    // Debt held by public
    let intragovernmental: Double   // Intragovernmental holdings
    let recordDate: Date
    let dailyIncreaseRate: Double   // Average daily increase
    
    var formattedTotalDebt: String {
        formatLargeNumber(totalDebt)
    }
    
    var formattedDebtHeldByPublic: String {
        formatLargeNumber(debtHeldByPublic)
    }
    
    /// Per second increase (for real-time animation)
    var perSecondIncrease: Double {
        dailyIncreaseRate / 86400.0
    }
    
    /// Per millisecond increase
    var perMillisecondIncrease: Double {
        perSecondIncrease / 1000.0
    }
    
    /// Calculate interpolated debt based on time elapsed since record date
    func interpolatedDebt(at date: Date = Date()) -> Double {
        let secondsElapsed = date.timeIntervalSince(recordDate)
        return totalDebt + (perSecondIncrease * secondsElapsed)
    }
    
    /// Debt per US citizen (population ~335 million)
    var debtPerCitizen: Double {
        totalDebt / 335_000_000
    }
    
    var formattedDebtPerCitizen: String {
        String(format: "$%.0f", debtPerCitizen)
    }
    
    /// Debt in BTC terms
    func debtInBTC(btcPrice: Double) -> Double {
        guard btcPrice > 0 else { return 0 }
        return totalDebt / btcPrice
    }
    
    func formattedDebtInBTC(btcPrice: Double) -> String {
        let btc = debtInBTC(btcPrice: btcPrice)
        if btc >= 1_000_000_000 {
            return String(format: "%.2fB BTC", btc / 1_000_000_000)
        } else if btc >= 1_000_000 {
            return String(format: "%.2fM BTC", btc / 1_000_000)
        }
        return String(format: "%.0f BTC", btc)
    }
    
    private func formatLargeNumber(_ value: Double) -> String {
        if value >= 1_000_000_000_000 {
            return String(format: "$%.3fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        }
        return String(format: "$%.0f", value)
    }
    
    // MARK: - Placeholder
    static var placeholder: USDebtData {
        USDebtData(
            totalDebt: 36_200_000_000_000,  // ~$36.2 trillion (Jan 2026 estimate)
            debtHeldByPublic: 28_500_000_000_000,
            intragovernmental: 7_700_000_000_000,
            recordDate: Date(),
            dailyIncreaseRate: 6_000_000_000  // ~$6 billion per day
        )
    }
}

// MARK: - Dollar Purchasing Power
struct DollarPurchasingPower: Identifiable {
    let id = UUID()
    let baseYear: Int
    let currentYear: Int
    let baseCPI: Double         // CPI in base year
    let currentCPI: Double      // CPI now
    
    /// How much of 1913 dollar's value remains
    var purchasingPowerRemaining: Double {
        guard currentCPI > 0 else { return 0 }
        return (baseCPI / currentCPI)
    }
    
    /// Percentage of value lost
    var percentageLost: Double {
        (1 - purchasingPowerRemaining) * 100
    }
    
    /// What $1 from base year is worth today
    var dollarValueToday: Double {
        purchasingPowerRemaining
    }
    
    /// What $100 from base year is worth today
    var hundredDollarsToday: Double {
        100 * purchasingPowerRemaining
    }
    
    /// How much you need today to match $1 from base year
    var equivalentToday: Double {
        guard baseCPI > 0 else { return 0 }
        return currentCPI / baseCPI
    }
    
    var formattedPercentageLost: String {
        String(format: "%.1f%%", percentageLost)
    }
    
    var formattedDollarValueToday: String {
        String(format: "$%.2f", dollarValueToday)
    }
    
    var formattedEquivalentToday: String {
        String(format: "$%.2f", equivalentToday)
    }
    
    // MARK: - Placeholder (1913 to 2026)
    static var placeholder: DollarPurchasingPower {
        // CPI in 1913 was ~9.9, CPI in 2025 is ~315
        DollarPurchasingPower(
            baseYear: 1913,
            currentYear: 2026,
            baseCPI: 9.9,
            currentCPI: 320.0  // Estimated Jan 2026
        )
    }
}

// MARK: - Historical CPI Data
struct HistoricalCPIData {
    /// CPI values by year (approximate annual averages)
    /// Base: 1982-1984 = 100
    static let cpiByYear: [Int: Double] = [
        1913: 9.9,
        1920: 20.0,
        1930: 16.7,
        1940: 14.0,
        1950: 24.1,
        1960: 29.6,
        1970: 38.8,
        1980: 82.4,
        1990: 130.7,
        2000: 172.2,
        2010: 218.1,
        2015: 237.0,
        2020: 258.8,
        2021: 271.0,
        2022: 292.7,
        2023: 304.7,
        2024: 312.0,
        2025: 318.0,
        2026: 320.0  // Estimate
    ]
    
    static func cpi(for year: Int) -> Double {
        if let exact = cpiByYear[year] {
            return exact
        }
        // Interpolate between known years
        let sortedYears = cpiByYear.keys.sorted()
        guard let lowerYear = sortedYears.last(where: { $0 <= year }),
              let upperYear = sortedYears.first(where: { $0 >= year }),
              let lowerCPI = cpiByYear[lowerYear],
              let upperCPI = cpiByYear[upperYear] else {
            return cpiByYear[2026] ?? 320.0
        }
        
        if lowerYear == upperYear {
            return lowerCPI
        }
        
        let ratio = Double(year - lowerYear) / Double(upperYear - lowerYear)
        return lowerCPI + (upperCPI - lowerCPI) * ratio
    }
    
    /// Calculate purchasing power loss between two years
    static func purchasingPowerLoss(from startYear: Int, to endYear: Int) -> DollarPurchasingPower {
        DollarPurchasingPower(
            baseYear: startYear,
            currentYear: endYear,
            baseCPI: cpi(for: startYear),
            currentCPI: cpi(for: endYear)
        )
    }
    
    /// Default: 1913 (Fed creation) to now
    static var since1913: DollarPurchasingPower {
        let currentYear = Calendar.current.component(.year, from: Date())
        return purchasingPowerLoss(from: 1913, to: currentYear)
    }
}

// MARK: - Debt Data Collection
struct DebtDataCollection {
    var usDebt: USDebtData?
    var purchasingPower: DollarPurchasingPower?
    var isLoading: Bool = false
    var error: String?
    var lastUpdated: Date?
    
    static var placeholder: DebtDataCollection {
        DebtDataCollection(
            usDebt: .placeholder,
            purchasingPower: .placeholder
        )
    }
    
    var isComplete: Bool {
        usDebt != nil && purchasingPower != nil
    }
}

// MARK: - Treasury API Response Models
struct TreasuryDebtResponse: Codable {
    let data: [TreasuryDebtRecord]
}

struct TreasuryDebtRecord: Codable {
    let recordDate: String
    let totPubDebtOutAmt: String?
    let debtHeldPublicAmt: String?
    let intragovHoldAmt: String?
    
    enum CodingKeys: String, CodingKey {
        case recordDate = "record_date"
        case totPubDebtOutAmt = "tot_pub_debt_out_amt"
        case debtHeldPublicAmt = "debt_held_public_amt"
        case intragovHoldAmt = "intragov_hold_amt"
    }
}
