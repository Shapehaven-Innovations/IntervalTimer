//
//  IntervalTimerApp.swift
//  IntervalTimer
//
//  Updated 06/04/25 to enforce a 7-day free trial before requiring subscription.
//

import SwiftUI
import AVFoundation
import StoreKit

@main
struct IntervalTimerApp: App {
    // ── Theme & Subscription Managers ──────────────────────────────────────────────
    @StateObject private var themeManager        = ThemeManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // ── Onboarding & Appearance Flags ──────────────────────────────────────────────
    @AppStorage("useDarkMode")   private var useDarkMode = false
    @AppStorage("hasOnboarded")  private var hasOnboarded = false

    // ── Trial logic: store the Unix timestamp of first launch ───────────────────────
    /// Stores a TimeInterval (seconds since 1970) marking the first time the app ever ran.
    @AppStorage("installDate") private var installDate: TimeInterval?

    init() {
        configureAudioSession()
        configureNavigationBarAppearance()

        // If there's no installDate yet, set it to now
        if installDate == nil {
            installDate = Date().timeIntervalSince1970
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeManager)
                .environmentObject(subscriptionManager)
                .preferredColorScheme(useDarkMode ? .dark : .light)
        }
    }

    // MARK: – Audio

    /// Configure AVAudioSession for playback with mixing.
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error)")
        }
    }

    // MARK: – Nav-Bar Appearance

    /// Make the navigation bar transparent, with adaptive title color.
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor            = UIColor.label
    }
}

