///
//  IntervalTimerApp.swift
//  IntervalTimer
//

import SwiftUI
import AVFoundation

@main
struct IntervalTimerApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("useDarkMode") private var useDarkMode: Bool = false
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    init() {
        configureAudioSession()
        configureNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            // If the user has never onboarded, show the OnboardingView first.
            if !hasOnboarded {
                OnboardingView()
                    .environmentObject(themeManager)
                    .preferredColorScheme(useDarkMode ? .dark : .light)
            } else {
                ContentView()
                    .environmentObject(themeManager)
                    .preferredColorScheme(useDarkMode ? .dark : .light)
            }
        }
    }

    // MARK: – Audio

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error)")
        }
    }

    // MARK: – Nav‑Bar Appearance

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        // Make the bar transparent so our background peeks through
        appearance.configureWithTransparentBackground()
        // White (or black, depending on scheme) large‑title text
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        // Small title too (just in case)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]

        // Apply to all states
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        // Gear icon and any bar‑button use this tint
        UINavigationBar.appearance().tintColor = UIColor.label
    }
}

