//
//  ThemeType.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//

import SwiftUI

/// All the themes your user can pick.
enum ThemeType: String, CaseIterable, Identifiable {
    case colorful = "Colorful"
    case dark     = "Dark"
    case light    = "Light"
    case flame    = "Flame"
    case ocean    = "Ocean"
    
    var id: String { rawValue }
    
    /// The eight “card” background colors.
    var cardBackgrounds: [Color] {
        switch self {
        case .colorful:
            return [.yellow, .mint, .green, .red,
                    .orange, .blue, .purple, .pink]
        case .dark:
            return Array(repeating: Color(.secondarySystemBackground), count: 8)
        case .light:
            return Array(repeating: Color(.systemBackground),         count: 8)
        case .flame:
            return [.red, .orange, .yellow,
                    .red.opacity(0.8), .orange.opacity(0.8), .yellow.opacity(0.8),
                    .red.opacity(0.6), .orange.opacity(0.6)]
        case .ocean:
            return [.blue, .teal, .cyan,
                    .blue.opacity(0.8), .teal.opacity(0.8), .cyan.opacity(0.8),
                    .blue.opacity(0.6), .teal.opacity(0.6)]
        }
    }
    
    /// Accent color (used for the Analytics tile, etc.)
    var accent: Color {
        switch self {
        case .colorful: return Color.accentColor
        case .dark:     return .white
        case .light:    return .blue
        case .flame:    return .orange
        case .ocean:    return .teal
        }
    }
}

