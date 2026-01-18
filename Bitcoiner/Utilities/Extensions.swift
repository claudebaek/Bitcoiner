//
//  Extensions.swift
//  Bitcoiner
//
//  Created by leejay100 on 1/17/26.
//

import SwiftUI

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Double Extensions
extension Double {
    var formattedWithSign: String {
        let sign = self >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, self)
    }
    
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    var formattedLargeNumber: String {
        let trillion = 1_000_000_000_000.0
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let thousand = 1_000.0
        
        if self >= trillion {
            return String(format: "$%.2fT", self / trillion)
        } else if self >= billion {
            return String(format: "$%.2fB", self / billion)
        } else if self >= million {
            return String(format: "$%.2fM", self / million)
        } else if self >= thousand {
            return String(format: "$%.1fK", self / thousand)
        } else {
            return String(format: "$%.0f", self)
        }
    }
    
    var formattedPercentage: String {
        String(format: "%.2f%%", self)
    }
}

// MARK: - Date Extensions
extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var shortTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var mediumDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .padding(AppLayout.padding)
            .background(AppColors.cardBackground)
            .cornerRadius(AppLayout.cornerRadius)
    }
    
    func secondaryCardStyle() -> some View {
        self
            .padding(AppLayout.smallPadding)
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppLayout.smallCornerRadius)
    }
    
    func glowEffect(color: Color, radius: CGFloat = 10) -> some View {
        self.shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
    }
}

// MARK: - Animation Extensions
extension Animation {
    static var smoothSpring: Animation {
        .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    }
    
    static var quickSpring: Animation {
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }
}

// MARK: - Int Extensions
extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - String Extensions
extension String {
    var toDouble: Double? {
        Double(self)
    }
    
    var toInt: Int? {
        Int(self)
    }
}
