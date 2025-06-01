// BackgroundOption.swift
//
//  BackgroundOption.swift
//  IntervalTimer
//
//  Created by user on 5/25/25.
//

import SwiftUI

/// The two backgrounds your user can choose.
enum BackgroundOption: String, CaseIterable, Identifiable {
    case black  = "Dark"
    case white  = "Light"

    var id: String { rawValue }

    /// The actual SwiftUI Color to apply.
    var color: Color {
        switch self {
        case .black:  return .black
        case .white:  return .white
        }
    }
}

