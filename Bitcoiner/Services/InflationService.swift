//
//  InflationService.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/19/26.
//

import Foundation

// MARK: - Inflation Service
final class InflationService {
    static let shared = InflationService()
    
    private let apiService: APIService
    private let worldBankBaseURL = "https://api.worldbank.org/v2"
    
    // Cache
    private var cachedData: [String: InflationAPIData] = [:]
    private var lastFetchDate: Date?
    private let cacheValidityDays: Int = 7  // Refresh weekly
    
    private init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Country Codes for High Inflation Nations
    /// ISO 3166-1 alpha-3 country codes
    static let targetCountries: [(code: String, name: String, flag: String, currency: String)] = [
        // Crisis Level
        ("VEN", "Venezuela", "🇻🇪", "Bolívar"),
        ("LBN", "Lebanon", "🇱🇧", "Lebanese Pound"),
        ("ARG", "Argentina", "🇦🇷", "Argentine Peso"),
        ("SYR", "Syria", "🇸🇾", "Syrian Pound"),
        // Severe
        ("SDN", "Sudan", "🇸🇩", "Sudanese Pound"),
        ("TUR", "Turkey", "🇹🇷", "Turkish Lira"),
        // High
        ("IRN", "Iran", "🇮🇷", "Iranian Rial"),
        ("EGY", "Egypt", "🇪🇬", "Egyptian Pound"),
        ("PAK", "Pakistan", "🇵🇰", "Pakistani Rupee"),
        ("NGA", "Nigeria", "🇳🇬", "Nigerian Naira"),
        ("SLE", "Sierra Leone", "🇸🇱", "Sierra Leonean Leone"),
        ("HTI", "Haiti", "🇭🇹", "Haitian Gourde"),
        ("ETH", "Ethiopia", "🇪🇹", "Ethiopian Birr"),
        ("GHA", "Ghana", "🇬🇭", "Ghanaian Cedi"),
        ("MWI", "Malawi", "🇲🇼", "Malawian Kwacha"),
        ("MMR", "Myanmar", "🇲🇲", "Myanmar Kyat"),
        ("ZWE", "Zimbabwe", "🇿🇼", "ZiG")
    ]
    
    // MARK: - Fetch Inflation Data
    /// Fetches inflation data for all target countries
    func fetchAllInflationData() async -> InflationDataCollection {
        var collection = InflationDataCollection()
        collection.isLoading = true
        
        // Check cache validity
        if let lastFetch = lastFetchDate,
           Date().timeIntervalSince(lastFetch) < Double(cacheValidityDays * 24 * 60 * 60),
           !cachedData.isEmpty {
            collection.countries = buildInflationCases(from: cachedData)
            collection.isLoading = false
            collection.lastUpdated = lastFetch
            collection.source = .cached
            return collection
        }
        
        // Fetch fresh data
        var fetchedData: [String: InflationAPIData] = [:]
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Fetch in parallel using TaskGroup
        await withTaskGroup(of: (String, InflationAPIData?).self) { group in
            for country in Self.targetCountries {
                group.addTask {
                    let data = await self.fetchCountryInflation(countryCode: country.code, year: currentYear)
                    return (country.code, data)
                }
            }
            
            for await (code, data) in group {
                if let data = data {
                    fetchedData[code] = data
                }
            }
        }
        
        // Update cache
        if !fetchedData.isEmpty {
            cachedData = fetchedData
            lastFetchDate = Date()
            collection.source = .api
        } else {
            collection.source = .fallback
        }
        
        collection.countries = buildInflationCases(from: fetchedData)
        collection.isLoading = false
        collection.lastUpdated = Date()
        
        return collection
    }
    
    // MARK: - Fetch Single Country
    private func fetchCountryInflation(countryCode: String, year: Int) async -> InflationAPIData? {
        // Try current year first, then previous year if no data
        for targetYear in [year, year - 1, year - 2] {
            let urlString = "\(worldBankBaseURL)/country/\(countryCode)/indicator/FP.CPI.TOTL.ZG?date=\(targetYear)&format=json"
            
            do {
                let response: WorldBankResponse = try await apiService.fetch(from: urlString)
                
                // World Bank returns array with [metadata, data]
                if let dataArray = response.data,
                   let firstRecord = dataArray.first,
                   let value = firstRecord.value {
                    return InflationAPIData(
                        countryCode: countryCode,
                        year: targetYear,
                        inflationRate: value,
                        indicator: "FP.CPI.TOTL.ZG"
                    )
                }
            } catch {
                print("Failed to fetch inflation for \(countryCode) (\(targetYear)): \(error)")
                continue
            }
        }
        
        return nil
    }
    
    // MARK: - Build Inflation Cases
    private func buildInflationCases(from apiData: [String: InflationAPIData]) -> [HyperinflationCase] {
        var cases: [HyperinflationCase] = []
        
        for country in Self.targetCountries {
            let tier: InflationTier
            let inflationRate: Double
            let formattedRate: String
            let year: String
            let description: String
            
            if let data = apiData[country.code] {
                // Use API data
                inflationRate = data.inflationRate
                year = String(data.year)
                formattedRate = formatInflationRate(data.inflationRate)
                tier = determineTier(for: data.inflationRate)
                description = getDescription(for: country.code, rate: data.inflationRate)
            } else {
                // Use fallback data
                let fallback = getFallbackData(for: country.code)
                inflationRate = fallback.rate
                year = fallback.year
                formattedRate = fallback.formatted
                tier = fallback.tier
                description = fallback.description
            }
            
            // Only include if inflation > 15%
            if inflationRate > 15 {
                cases.append(HyperinflationCase(
                    country: country.name,
                    countryCode: country.code,
                    flagEmoji: country.flag,
                    currency: country.currency,
                    year: year,
                    peakInflation: formattedRate,
                    inflationValue: inflationRate,
                    category: .current,
                    tier: tier,
                    description: description
                ))
            }
        }
        
        // Sort by inflation rate (highest first)
        return cases.sorted { $0.inflationValue > $1.inflationValue }
    }
    
    // MARK: - Helpers
    private func formatInflationRate(_ rate: Double) -> String {
        if rate >= 1000 {
            return String(format: "%.1fK%%", rate / 1000)
        } else if rate >= 100 {
            return String(format: "%.0f%%", rate)
        } else {
            return String(format: "%.1f%%", rate)
        }
    }
    
    private func determineTier(for rate: Double) -> InflationTier {
        if rate >= 100 {
            return .crisis
        } else if rate >= 50 {
            return .severe
        } else {
            return .high
        }
    }
    
    private func getDescription(for countryCode: String, rate: Double) -> String {
        let descriptions: [String: String] = [
            "VEN": "Chronic economic crisis with currency collapse",
            "LBN": "Economic collapse since 2019 banking crisis",
            "ARG": "Persistent inflation despite reforms",
            "SYR": "War and sanctions impact on economy",
            "SDN": "Civil war causing economic devastation",
            "TUR": "Unorthodox monetary policy effects",
            "IRN": "International sanctions impact",
            "EGY": "Currency crisis and devaluation",
            "PAK": "Economic instability and IMF conditions",
            "NGA": "Currency devaluation and reforms",
            "SLE": "Economic challenges and currency weakness",
            "HTI": "Political instability and gang violence",
            "ETH": "Post-conflict economic recovery",
            "GHA": "Debt crisis and currency depreciation",
            "MWI": "Currency devaluation pressures",
            "MMR": "Post-coup economic collapse",
            "ZWE": "Recurring inflation cycles"
        ]
        return descriptions[countryCode] ?? "High inflation environment"
    }
    
    private func getFallbackData(for countryCode: String) -> (rate: Double, year: String, formatted: String, tier: InflationTier, description: String) {
        // Fallback data based on latest known values
        let fallbacks: [String: (rate: Double, year: String)] = [
            "VEN": (190, "2025"),
            "LBN": (45, "2024"),
            "ARG": (32, "2025"),
            "SYR": (57, "2024"),
            "SDN": (140, "2025"),
            "TUR": (58, "2024"),
            "IRN": (45, "2024"),
            "EGY": (35, "2024"),
            "PAK": (30, "2024"),
            "NGA": (30, "2024"),
            "SLE": (30, "2024"),
            "HTI": (25, "2024"),
            "ETH": (25, "2024"),
            "GHA": (25, "2024"),
            "MWI": (25, "2024"),
            "MMR": (20, "2024"),
            "ZWE": (20, "2024")
        ]
        
        let data = fallbacks[countryCode] ?? (20, "2024")
        return (
            rate: data.rate,
            year: data.year,
            formatted: formatInflationRate(data.rate),
            tier: determineTier(for: data.rate),
            description: getDescription(for: countryCode, rate: data.rate)
        )
    }
}

// MARK: - World Bank API Response Models
struct WorldBankResponse: Codable {
    let data: [WorldBankDataRecord]?
    
    init(from decoder: Decoder) throws {
        // World Bank returns [[metadata], [data]] format
        var container = try decoder.unkeyedContainer()
        
        // Skip metadata (first element)
        _ = try? container.decode(WorldBankMetadata.self)
        
        // Decode data array (second element)
        data = try? container.decode([WorldBankDataRecord].self)
    }
}

struct WorldBankMetadata: Codable {
    let page: Int?
    let pages: Int?
    let perPage: String?
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case page, pages, total
        case perPage = "per_page"
    }
}

struct WorldBankDataRecord: Codable {
    let indicator: WorldBankIndicator?
    let country: WorldBankCountry?
    let countryiso3code: String?
    let date: String?
    let value: Double?
    let unit: String?
    let obsStatus: String?
    let decimal: Int?
    
    enum CodingKeys: String, CodingKey {
        case indicator, country, countryiso3code, date, value, unit, decimal
        case obsStatus = "obs_status"
    }
}

struct WorldBankIndicator: Codable {
    let id: String?
    let value: String?
}

struct WorldBankCountry: Codable {
    let id: String?
    let value: String?
}

// MARK: - Inflation API Data
struct InflationAPIData {
    let countryCode: String
    let year: Int
    let inflationRate: Double
    let indicator: String
}

// MARK: - Inflation Data Collection
struct InflationDataCollection {
    var countries: [HyperinflationCase] = []
    var isLoading: Bool = false
    var error: String?
    var lastUpdated: Date?
    var source: DataSource = .fallback
    
    enum DataSource {
        case api
        case cached
        case fallback
    }
    
    var sourceDescription: String {
        switch source {
        case .api: return "World Bank API"
        case .cached: return "Cached data"
        case .fallback: return "Estimated data"
        }
    }
    
    // Group by tier
    var byTier: [InflationTier: [HyperinflationCase]] {
        Dictionary(grouping: countries, by: { $0.tier })
    }
    
    var crisisCount: Int {
        countries.filter { $0.tier == .crisis }.count
    }
    
    var severeCount: Int {
        countries.filter { $0.tier == .severe }.count
    }
    
    var highCount: Int {
        countries.filter { $0.tier == .high }.count
    }
}
