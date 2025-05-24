//
//  ThemeManager.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//

import SwiftUI
import Combine

/// Observable theme store: when `selected` changes, views watching it will update.
final class ThemeManager: ObservableObject {
    @Published var selected: ThemeType
    
    /// Singleton instance
    static let shared = ThemeManager()
    
    private var cancellable: AnyCancellable?
    
    private init() {
        // Load from UserDefaults (default to .colorful)
        let raw = UserDefaults.standard.string(forKey: "selectedTheme")
                ?? ThemeType.colorful.rawValue
        selected = ThemeType(rawValue: raw) ?? .colorful
        
        // Persist any updates
        cancellable = $selected
            .sink { new in
                UserDefaults.standard.set(new.rawValue, forKey: "selectedTheme")
            }
    }
}
