//
//  SoundType.swift
//  IntervalTimer
//
//  Created by You on 2025‑06‑01.
//  A static list of all built‑in sounds the user can pick.
//  rawValue = user‑facing display name ("Beep", "Chime", "Bell", etc).

import Foundation

enum SoundType: String, CaseIterable, Identifiable {
    /// Display name = “Beep”   (expects “beep.wav” in the bundle)
    case beep   = "Beep"
    /// Display name = “Beem”   (expects “beem.wav” in the bundle)
    case beem   = "Beem"
    /// Display name = “Alert”  (expects “alert.wav” in the bundle)
    case alert  = "Alert"
    /// Display name = “Laser”  (expects “laser.wav” in the bundle)
    case laser  = "Laser"
    /// Display name = “Ding”   (expects “ding.wav” in the bundle)
    case ding   = "Ding"
    /// Display name = “Hop”    (expects “hop.wav” in the bundle)
    case hop    = "Hop"
    /// Display name = “Heep”   (expects “heep.wav” in the bundle)
    case heep   = "Heep"
    /// Display name = “Bell”   (expects “bell.wav” in the bundle)
    case bell   = "Bell"
    /// Display name = “Chime”  (expects “chime.mp3” in the bundle)
    case chime  = "Chime"

    var id: String { rawValue }

    ///
    /// The actual filename (no extension) that must exist in your bundle root.
    /// For example:
    ///   • “beep.wav”
    ///   • “chime.mp3”
    ///   • etc.
    ///
    var fileName: String {
        switch self {
        case .beep:
            return "beep"   // beep.wav
        case .beem:
            return "beem"   // beem.wav
        case .alert:
            return "alert"  // alert.wav
        case .laser:
            return "laser"  // laser.wav
        case .ding:
            return "ding"   // ding.wav
        case .hop:
            return "hop"    // hop.wav
        case .heep:
            return "heep"   // heep.wav
        case .bell:
            return "bell"   // bell.wav
        case .chime:
            return "chime"  // chime.mp3
        }
    }

    ///
    /// Given a lowercase fileName (e.g. "laser"), returns the corresponding SoundType.
    /// If there’s no match, defaults to `.beep`.
    ///
    static func fromFileName(_ name: String) -> SoundType {
        return SoundType.allCases.first { $0.fileName == name } ?? .beep
    }
}

