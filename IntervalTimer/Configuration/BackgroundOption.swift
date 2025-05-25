//
//  BackgroundOption.swift
//  IntervalTimer
//
//  Created by You on 5/25/25.
//

import SwiftUI

/// The four backgrounds your user can choose.
enum BackgroundOption: String, CaseIterable, Identifiable {
    case black  = "Black"
    case white  = "White"
    case orange = "Orange"
    case blue   = "Blue"

    var id: String { rawValue }

    /// The actual SwiftUI Color to apply.
    var color: Color {
        switch self {
        case .black:  return .black
        case .white:  return .white
        case .orange: return .orange
        case .blue:
            // “Light lumination” blue
            return Color.blue.opacity(0.2)
        }
    }
}
