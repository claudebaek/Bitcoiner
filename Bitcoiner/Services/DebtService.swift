//
//  DebtService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/18/26.
//

import Foundation

// MARK: - Debt Service
final class DebtService {
    static let shared = DebtService()
    
    private let apiService: APIService
    private let baseURL = "https://api.fiscaldata.treasury.gov/services/api/fiscal_service/v2/accounting/od/debt_to_penny"
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Current US Debt
    func fetchUSDebt() async throws -> USDebtData {
        // Build URL with query parameters
        let urlString = "\(baseURL)?fields=record_date,tot_pub_debt_out_amt,debt_held_public_amt,intragov_hold_amt&sort=-record_date&page[size]=2"
        
        do {
            let response: TreasuryDebtResponse = try await apiService.fetch(from: urlString)
            
            guard let latestRecord = response.data.first else {
                throw DebtServiceError.noData
            }
            
            // Parse debt values
            let totalDebt = Double(latestRecord.totPubDebtOutAmt ?? "0") ?? 0
            let debtHeldByPublic = Double(latestRecord.debtHeldPublicAmt ?? "0") ?? 0
            let intragovernmental = Double(latestRecord.intragovHoldAmt ?? "0") ?? 0
            
            // Parse record date
            let recordDate = parseDate(latestRecord.recordDate) ?? Date()
            
            // Calculate daily increase rate from last two records
            var dailyIncreaseRate = 6_000_000_000.0  // Default: ~$6B/day
            
            if response.data.count >= 2 {
                let previousRecord = response.data[1]
                let previousDebt = Double(previousRecord.totPubDebtOutAmt ?? "0") ?? 0
                let previousDate = parseDate(previousRecord.recordDate) ?? Date()
                
                let daysDiff = recordDate.timeIntervalSince(previousDate) / 86400
                if daysDiff > 0 {
                    dailyIncreaseRate = (totalDebt - previousDebt) / daysDiff
                    // Clamp to reasonable values (negative means debt decreased, rare but possible)
                    dailyIncreaseRate = max(dailyIncreaseRate, 0)
                }
            }
            
            return USDebtData(
                totalDebt: totalDebt,
                debtHeldByPublic: debtHeldByPublic,
                intragovernmental: intragovernmental,
                recordDate: recordDate,
                dailyIncreaseRate: dailyIncreaseRate
            )
        } catch {
            print("Failed to fetch US debt: \(error)")
            // Return fallback data
            return .placeholder
        }
    }
    
    // MARK: - Fetch Purchasing Power Data
    func fetchPurchasingPower() -> DollarPurchasingPower {
        // Use hardcoded CPI data (BLS API would require registration)
        return HistoricalCPIData.since1913
    }
    
    // MARK: - Fetch All Debt Data
    func fetchAllDebtData() async -> DebtDataCollection {
        var collection = DebtDataCollection()
        collection.isLoading = true
        
        // Fetch US debt from Treasury API
        do {
            collection.usDebt = try await fetchUSDebt()
        } catch {
            print("Failed to fetch US debt: \(error)")
            collection.usDebt = .placeholder
            collection.error = error.localizedDescription
        }
        
        // Get purchasing power data (hardcoded, instant)
        collection.purchasingPower = fetchPurchasingPower()
        
        collection.isLoading = false
        collection.lastUpdated = Date()
        return collection
    }
    
    // MARK: - Helpers
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

// MARK: - Debt Service Error
enum DebtServiceError: LocalizedError {
    case noData
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No debt data available"
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from Treasury API"
        }
    }
}
