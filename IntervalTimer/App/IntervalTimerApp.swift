// IntervalTimerApp.swift
// IntervalTimer
// Entry point with animated onboarding → ContentView transition

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
            Group {
                if hasOnboarded {
                    ContentView()
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                } else {
                    OnboardingView()
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            )
                        )
                }
            }
            .animation(.easeInOut(duration: 0.6), value: hasOnboarded)
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

