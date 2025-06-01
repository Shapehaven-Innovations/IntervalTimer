// PickerType.swift
//
//  PickerType.swift
//  IntervalTimer
//
//  Created by user on 5/26/25.
//

import SwiftUI

/// Extracted from ContentView so ConfigTilesView & PickerSheet can share it.
enum PickerType: Int, Identifiable {
    case getReady, rounds, work, rest

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .getReady: return "Get Ready"
        case .rounds:   return "Rounds"
        case .work:     return "Work"
        case .rest:     return "Rest"
        }
    }
}

