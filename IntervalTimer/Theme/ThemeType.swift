// ThemeType.swift
// IntervalTimer
// Updated 05/25/25 to include emotional, trending palettes

import SwiftUI

enum ThemeType: String, CaseIterable, Identifiable {
    case pastelMinimal = "Pastel"
    case neonPop       = "Neon"
    case nature        = "Nature"
    case light         = "Light"
    case dark          = "Dark"
    
    var id: String { rawValue }
    
    /// Eight card background colors per theme
    var cardBackgrounds: [Color] {
        switch self {
        case .pastelMinimal:
            return [
                Color(red: 1.00, green: 0.70, blue: 0.72),
                Color(red: 1.00, green: 0.87, blue: 0.73),
                Color(red: 1.00, green: 1.00, blue: 0.73),
                Color(red: 0.73, green: 1.00, blue: 0.78),
                Color(red: 0.73, green: 0.88, blue: 1.00),
                Color(red: 0.84, green: 0.73, blue: 1.00),
                Color(red: 1.00, green: 0.73, blue: 0.95),
                Color(red: 0.75, green: 1.00, blue: 0.84)
            ]
        case .neonPop:
            return [
                Color(red: 1.00, green: 0.43, blue: 0.78),
                Color(red: 1.00, green: 0.85, blue: 0.24),
                Color(red: 0.20, green: 1.00, blue: 0.42),
                Color(red: 0.02, green: 0.68, blue: 0.84),
                Color(red: 0.55, green: 0.04, blue: 1.00),
                Color(red: 1.00, green: 0.00, blue: 0.43),
                Color(red: 0.01, green: 0.94, blue: 0.77),
                Color(red: 1.00, green: 0.62, blue: 0.11)
            ]
        case .nature:
            return [
                Color(red: 0.18, green: 0.55, blue: 0.34),
                Color(red: 0.24, green: 0.71, blue: 0.44),
                Color(red: 0.56, green: 0.74, blue: 0.56),
                Color(red: 0.33, green: 0.42, blue: 0.19),
                Color(red: 0.42, green: 0.56, blue: 0.14),
                Color(red: 0.13, green: 0.55, blue: 0.13),
                Color(red: 0.40, green: 0.80, blue: 0.67),
                Color(red: 0.50, green: 1.00, blue: 0.00)
            ]
        case .light:
            let silver = Color(UIColor.lightGray)
            let gold   = Color(red: 212/255, green: 175/255, blue: 55/255)
            return [
                silver, gold,
                silver.opacity(0.8), gold.opacity(0.8),
                silver.opacity(0.6), gold.opacity(0.6),
                silver.opacity(0.4), gold.opacity(0.4)
            ]
        case .dark:
            return Array(repeating: Color(.secondarySystemBackground), count: 8)
        }
    }
    
    /// Accent color for buttons, nav bars, banners
    var accent: Color {
        switch self {
        case .pastelMinimal: return Color.pink
        case .neonPop:       return Color.purple
        case .nature:        return Color.green
        case .light:         return Color.blue
        case .dark:          return Color.white
        }
    }
    
    /// Overall background for every screen
    var backgroundColor: Color {
        switch self {
        case .pastelMinimal, .nature, .light:
            return Color(.systemBackground)
        case .neonPop, .dark:
            return .black
        }
    }
}

