// Theme.swift
// Centralized theme definitions for IntervalTimer

import SwiftUI

/// A centralized place for theme colors used across the app.
struct Theme {
    /// Card background colors, cycled through by index.
    static let cardBackgrounds: [Color] = [
        .yellow,
        .mint,
        .green,
        .red,
        .orange,
        .blue,
        .purple,
        .pink
    ]
    
    /// Accent color for labels and icons (same as .accentColor by default)
    static var accent: Color { Color.accentColor }
}
