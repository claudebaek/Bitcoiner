//
//  FearGreedIndex.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import Foundation
import SwiftUI

// MARK: - Alternative.me API Response
struct FearGreedResponse: Codable {
    let name: String
    let data: [FearGreedData]
}

struct FearGreedData: Codable {
    let value: String
    let valueClassification: String
    let timestamp: String
    let timeUntilUpdate: String?
    
    enum CodingKeys: String, CodingKey {
        case value
        case valueClassification = "value_classification"
        case timestamp
        case timeUntilUpdate = "time_until_update"
    }
}

// MARK: - App Model
struct FearGreedIndex: Identifiable {
    let id = UUID()
    let value: Int
    let classification: FearGreedClassification
    let timestamp: Date
    let historicalData: [FearGreedHistoryPoint]
    
    var formattedValue: String {
        "\(value)"
    }
    
    static var placeholder: FearGreedIndex {
        FearGreedIndex(
            value: 50,
            classification: .neutral,
            timestamp: Date(),
            historicalData: []
        )
    }
}

struct FearGreedHistoryPoint: Identifiable {
    let id = UUID()
    let value: Int
    let date: Date
}

enum FearGreedClassification: String, CaseIterable {
    case extremeFear = "Extreme Fear"
    case fear = "Fear"
    case neutral = "Neutral"
    case greed = "Greed"
    case extremeGreed = "Extreme Greed"
    
    var localizedName: String {
        switch self {
        case .extremeFear:
            return L10n.extremeFear
        case .fear:
            return L10n.fear
        case .neutral:
            return L10n.neutral
        case .greed:
            return L10n.greed
        case .extremeGreed:
            return L10n.extremeGreed
        }
    }
    
    var color: Color {
        switch self {
        case .extremeFear:
            return Color(hex: "FF5252")
        case .fear:
            return Color(hex: "FF8A65")
        case .neutral:
            return Color(hex: "FFD54F")
        case .greed:
            return Color(hex: "81C784")
        case .extremeGreed:
            return Color(hex: "00C853")
        }
    }
    
    var emoji: String {
        switch self {
        case .extremeFear:
            return "😱"
        case .fear:
            return "😨"
        case .neutral:
            return "😐"
        case .greed:
            return "😀"
        case .extremeGreed:
            return "🤑"
        }
    }
    
    static func from(value: Int) -> FearGreedClassification {
        switch value {
        case 0...24:
            return .extremeFear
        case 25...44:
            return .fear
        case 45...55:
            return .neutral
        case 56...75:
            return .greed
        default:
            return .extremeGreed
        }
    }
    
    static func from(string: String) -> FearGreedClassification {
        switch string.lowercased() {
        case "extreme fear":
            return .extremeFear
        case "fear":
            return .fear
        case "neutral":
            return .neutral
        case "greed":
            return .greed
        case "extreme greed":
            return .extremeGreed
        default:
            return .neutral
        }
    }
}
