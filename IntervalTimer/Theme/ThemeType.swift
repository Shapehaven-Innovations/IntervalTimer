//
//  ThemeType.swift
//  IntervalTimer
//  Updated 05/27/25 to give Rave a nature‑inspired greens & browns palette
//

import SwiftUI

enum ThemeType: String, CaseIterable, Identifiable {
    case rave      = "Nature"
    case neonPop   = "Neon"
    case starburst = "Starburst"
    case gamer     = "Gamer"
    case ocean     = "Ocean"

    var id: String { rawValue }

    /// Eight card background colors per theme
    var cardBackgrounds: [Color] {
        switch self {
        case .rave:
            // nature‑inspired greens & browns
            return [
                Color(red: 0.13, green: 0.55, blue: 0.13), // forest green
                Color(red: 0.24, green: 0.71, blue: 0.44), // medium sea green
                Color(red: 0.42, green: 0.56, blue: 0.14), // olive green
                Color(red: 0.56, green: 0.74, blue: 0.56), // light green
                Color(red: 0.33, green: 0.42, blue: 0.19), // dark olive
                Color(red: 0.55, green: 0.27, blue: 0.07), // saddle brown
                Color(red: 0.71, green: 0.40, blue: 0.11), // sienna
                Color(red: 0.80, green: 0.80, blue: 0.50)  // khaki
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

        case .starburst:
            return [
                Color(red: 1.00, green: 0.41, blue: 0.71),
                Color(red: 1.00, green: 0.84, blue: 0.00),
                Color(red: 1.00, green: 0.55, blue: 0.00),
                Color(red: 1.00, green: 0.65, blue: 0.00),
                Color(red: 1.00, green: 0.71, blue: 0.76),
                Color(red: 1.00, green: 1.00, blue: 0.88),
                Color(red: 1.00, green: 0.85, blue: 0.73),
                Color(red: 1.00, green: 0.50, blue: 0.31)
            ]

        case .gamer:
            return [
                Color(red: 0.00, green: 0.90, blue: 0.90),
                Color(red: 0.75, green: 0.00, blue: 1.00),
                Color(red: 1.00, green: 0.00, blue: 0.50),
                Color(red: 0.00, green: 0.50, blue: 1.00),
                Color(red: 1.00, green: 0.20, blue: 0.20),
                Color(red: 0.00, green: 1.00, blue: 0.00),
                Color(red: 0.10, green: 0.10, blue: 0.15),
                Color(red: 0.60, green: 0.00, blue: 0.60)
            ]

        case .ocean:
            return [
                Color(red: 0.00, green: 0.12, blue: 0.25),
                Color(red: 0.00, green: 0.50, blue: 0.50),
                Color(red: 0.18, green: 0.55, blue: 0.34),
                Color(red: 0.13, green: 0.70, blue: 0.67),
                Color(red: 0.50, green: 1.00, blue: 0.83),
                Color(red: 0.53, green: 0.81, blue: 0.92),
                Color(red: 0.69, green: 0.88, blue: 0.90),
                Color(red: 0.60, green: 0.98, blue: 0.60)
            ]
        }
    }

    /// Accent color for buttons, nav bars, banners
    var accent: Color {
        switch self {
        case .rave:      return Color(red: 0.33, green: 0.42, blue: 0.19) // dark olive
        case .neonPop:   return .purple
        case .starburst: return .orange
        case .gamer:     return Color(red: 0.00, green: 0.90, blue: 0.90)
        case .ocean:     return .blue
        }
    }

    /// Overall background for every screen
    var backgroundColor: Color {
        switch self {
        case .rave, .ocean, .starburst:
            return Color(.systemBackground)
        case .neonPop, .gamer:
            return .black
        }
    }
}

