// ThemeType.swift
//
//  ThemeType.swift
//  IntervalTimer
//  Updated 05/27/25 to darken Start Workout, Save Workout, Workout Log, and Intention tiles in Ocean theme
//

import SwiftUI

enum ThemeType: String, CaseIterable, Identifiable {
    case nature    = "Nature"
    case neonPop   = "Neon"
    case starburst = "Starburst"
    case gamer     = "Gamer"
    case ocean     = "Ocean"

    var id: String { rawValue }

    /// Eight card background colors per theme
    var cardBackgrounds: [Color] {
        switch self {
        case .nature:
            return [
                Color(red: 0.13, green: 0.55, blue: 0.13),
                Color(red: 0.24, green: 0.71, blue: 0.44),
                Color(red: 0.42, green: 0.56, blue: 0.14),
                Color(red: 0.56, green: 0.74, blue: 0.56),
                Color(red: 0.33, green: 0.42, blue: 0.19),
                Color(red: 0.55, green: 0.27, blue: 0.07),
                Color(red: 0.71, green: 0.40, blue: 0.11),
                Color(red: 0.80, green: 0.80, blue: 0.50)
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
                Color(red: 0.85, green: 0.30, blue: 0.60),
                Color(red: 1.00, green: 0.65, blue: 0.30),
                Color(red: 0.70, green: 0.35, blue: 0.30),
                Color(red: 0.80, green: 0.30, blue: 0.20)
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
            // darkened entries for indices 4–7
            return [
                Color(red: 0.00, green: 0.12, blue: 0.25), // deep navy
                Color(red: 0.00, green: 0.50, blue: 0.50), // teal
                Color(red: 0.18, green: 0.55, blue: 0.34), // sea green
                Color(red: 0.13, green: 0.70, blue: 0.67), // light sea green
                Color(red: 0.30, green: 0.70, blue: 0.50), // darker aquamarine (Start Workout)
                Color(red: 0.40, green: 0.60, blue: 0.70), // darker sky blue (Save Workout)
                Color(red: 0.50, green: 0.70, blue: 0.75), // darker powder blue (Workout Log)
                Color(red: 0.40, green: 0.70, blue: 0.40)  // darker pale green (Intention)
            ]
        }
    }

    /// Accent color for buttons, nav bars, banners
    var accent: Color {
        switch self {
        case .nature:    return Color(red: 0.33, green: 0.42, blue: 0.19)
        case .neonPop:   return .purple
        case .starburst: return .orange
        case .gamer:     return Color(red: 0.00, green: 0.90, blue: 0.90)
        case .ocean:     return .blue
        }
    }

    /// Overall background for every screen
    var backgroundColor: Color {
        switch self {
        case .nature, .ocean, .starburst:
            return Color(.systemBackground)
        case .neonPop, .gamer:
            return .black
        }
    }
}

