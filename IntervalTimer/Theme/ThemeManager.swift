// ThemeManager.swift
//
//  ThemeManager.swift
//  IntervalTimer
//  Updated 05/27/25 to default to Neon and persist any new choice
//

import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    @Published var selected: ThemeType

    static let shared = ThemeManager()
    private var cancellable: AnyCancellable?

    private init() {
        // Load last‑saved or default to neonPop
        let raw = UserDefaults.standard.string(forKey: "selectedTheme")
                  ?? ThemeType.neonPop.rawValue
        selected = ThemeType(rawValue: raw) ?? .neonPop

        // Persist future changes
        cancellable = $selected
            .sink { new in
                UserDefaults.standard.set(new.rawValue, forKey: "selectedTheme")
            }
    }
}

