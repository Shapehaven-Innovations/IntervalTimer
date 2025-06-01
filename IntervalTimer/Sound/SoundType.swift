// SoundType.swift
//
//  SoundType.swift
//  IntervalTimer
//
//  Created on 06/01/25.
//

import Foundation

/// All the built‑in sounds the user can pick for each phase.
/// - rawValue = user‑facing display name.
/// - fileName = the actual asset name (e.g. “beep”, “chime”, “bell”) that you must add to your Assets.xcassets.
///
/// NOTE: This enum is now optional, since our dynamic loader (SoundSettingsView) will pick up anything in mySounds/.
enum SoundType: String, CaseIterable, Identifiable {
    case beep   = "Beep"
    case chime  = "Chime"
    case bell   = "Bell"

    var id: String { rawValue }

    /// The name of the NSDataAsset or bundled sound file in your app bundle.
    var fileName: String {
        switch self {
        case .beep:  return "beep"
        case .chime: return "chime"
        case .bell:  return "bell"
        }
    }
}

