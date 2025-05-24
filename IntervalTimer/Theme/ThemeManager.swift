//
//  ThemeManager.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//

import SwiftUI
import Combine

/// Observable theme store.  When `selected` changes, SwiftUI views observing it will update.
final class ThemeManager: ObservableObject {
    @Published var selected: ThemeType
    
    static let shared = ThemeManager()
    private var cancellable: AnyCancellable?
    
    private init() {
        // Load last‑saved theme (default to .colorful)
        let raw = UserDefaults.standard.string(forKey: "selectedTheme")
                ?? ThemeType.colorful.rawValue
        selected = ThemeType(rawValue: raw) ?? .colorful
        
        // Persist any future changes
        cancellable = $selected
            .sink { new in
                UserDefaults.standard.set(new.rawValue, forKey: "selectedTheme")
            }
    }
}

