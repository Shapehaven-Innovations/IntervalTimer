//
//  IntervalTimerApp.swift
//  IntervalTimer
//

import SwiftUI
import AVFoundation

@main
struct IntervalTimerApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    init() { configureAudioSession() }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasOnboarded {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(themeManager)
            .animation(.easeInOut(duration: 0.6), value: hasOnboarded)
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error)")
        }
    }
}

