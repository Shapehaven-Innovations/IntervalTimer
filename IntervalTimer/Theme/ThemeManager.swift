// ThemeManager.swift
// IntervalTimer
// Updated 05/25/25 to default to Pastel Minimal and persist any new choice

import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    @Published var selected: ThemeType
    
    static let shared = ThemeManager()
    private var cancellable: AnyCancellable?
    
    private init() {
        // Load last-saved or default to Pastel Minimal
        let raw = UserDefaults.standard.string(forKey: "selectedTheme")
                  ?? ThemeType.pastelMinimal.rawValue
        selected = ThemeType(rawValue: raw) ?? .pastelMinimal
        
        // Persist future changes
        cancellable = $selected
            .sink { new in
                UserDefaults.standard.set(new.rawValue, forKey: "selectedTheme")
            }
    }
}

