// RootView.swift
// IntervalTimer
//
// A minimal “router” that picks which screen to show based on trial, subscription & onboarding:
//
//    • If within 3-day free trial  → ContentView (no paywall)
//    • Else if not subscribed      → SubscriptionView
//    • Else if not onboarded       → OnboardingView
//    • Otherwise                   → ContentView

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    
    // Access the same “installDate” we saved in IntervalTimerApp
    @AppStorage("installDate") private var installDate: TimeInterval?
    
    // The length of the free trial (in seconds)
    private let trialLengthSeconds: TimeInterval = 3 * 24 * 60 * 60 // 3 days
    
    /// Computed property: true if “now” is still within 3 days of installDate
    private var isWithinTrial: Bool {
        guard let first = installDate else {
            return false // if for some reason it’s missing, treat as no trial
        }
        return Date().timeIntervalSince1970 < (first + trialLengthSeconds)
    }
    
    var body: some View {
        Group {
            if isWithinTrial {
                // ── Free trial is still active → show normal app
                if !hasOnboarded {
                    OnboardingView()
                } else {
                    ContentView()
                }
            } else {
                // ── Trial expired. Now check subscription status.
                if subscriptionManager.isSubscribed {
                    // Subscribed → next, check onboarding
                    if !hasOnboarded {
                        OnboardingView()
                    } else {
                        ContentView()
                    }
                } else {
                    // Trial over AND not subscribed → show paywall
                    SubscriptionView()
                }
            }
        }
    }
}

