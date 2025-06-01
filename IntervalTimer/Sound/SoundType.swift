//
//  SoundType.swift
//  IntervalTimer
//
//  Created by user on 6/1/25.
//


//
//  SoundType.swift
//  IntervalTimer
//
//  Created on 06/01/25.
//

import Foundation

/// All the built‑in sounds the user can pick for each phase.
/// - rawValue = user‑facing display name.
/// - fileName = the actual asset name (e.g. “beep”, “chime”, “bell”) that must exist in your xcassets or as a data asset.
enum SoundType: String, CaseIterable, Identifiable {
    case beep   = "Beep"
    case chime  = "Chime"
    case bell   = "Bell"

    var id: String { rawValue }

    /// The exact name of the NSDataAsset or sound file in Assets.xcassets.
    var fileName: String {
        switch self {
        case .beep:  return "beep"
        case .chime: return "chime"
        case .bell:  return "bell"
        }
    }
}
