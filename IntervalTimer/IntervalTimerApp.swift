// IntervalTimerApp.swift
// IntervalTimer
// Entry point

import SwiftUI
import AVFoundation

@main
struct IntervalTimerApp: App {
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
