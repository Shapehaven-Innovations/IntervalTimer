// IntervalTimerApp.swift
// IntervalTimer
// Entry point with onboarding gating

import SwiftUI
import AVFoundation

@main
struct IntervalTimerApp: App {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }

    /// Configure AVAudioSession at launch so our cues mix with any background music
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

