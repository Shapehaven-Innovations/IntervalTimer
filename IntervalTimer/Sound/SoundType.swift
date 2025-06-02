//
//  SoundType.swift
//  IntervalTimer
//
//  Created by You on 2025‑06‑01.
//  A static list of all built‑in sounds the user can pick.
//  rawValue = user‑facing display name ("Beep", "Chime", "Bell").
//  fileName = the lowercase filename (no extension) that actually lives in the bundle root.
//

import Foundation

enum SoundType: String, CaseIterable, Identifiable {
    /// Display name = “Beep”
    case beep   = "Beep"
    /// Display name = “Chime”
    case chime  = "Chime"
    /// Display name = “Bell”
    case bell   = "Bell"

    var id: String { rawValue }

    /// The actual filename (no extension) that must exist in the bundle root.
    /// For example, if you dragged “beep.wav” into Copy Bundle Resources, then fileName = "beep".
    var fileName: String {
        switch self {
        case .beep:
            return "beep"   // expects “beep.wav”
        case .chime:
            return "chime"  // expects “chime.mp3”
        case .bell:
            return "bell"   // expects “bell.wav”
        }
    }

    /// Given a lowercase fileName (e.g. "beep"), returns the corresponding SoundType.
    /// If there’s no match, defaults to `.beep`.
    static func fromFileName(_ name: String) -> SoundType {
        return SoundType.allCases.first { $0.fileName == name } ?? .beep
    }
}

