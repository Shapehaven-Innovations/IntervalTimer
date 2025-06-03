//
//  ContentView.swift
//  IntervalTimer
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            // ─── ScrollView is the only thing under NavigationView ───
            ScrollView {
                VStack(spacing: 0) {
                    // ─── 1) “Hello, <device>!” is now part of the scrollable content ───
                    Text("Hello, \(UIDevice.current.name)!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // ─── 2) Your existing grid of tiles ───
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 20
                    ) {
                        ConfigTilesView()
                        ActionTilesView()
                        // …any other tile views you have…
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            // ─── 3) Tell SwiftUI “no title here” so the nav bar stays blank ───
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)

            // ─── 4) Gear icon in the toolbar (always visible at top‑right) ───
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(themeManager)
            }
            // ─── 5) Background‐color‐under‐nav so there’s no flash of white/black ───
            .background(Color(.systemBackground).ignoresSafeArea())
        }
        // ─── 6) Force single‑column on iPhone (avoid side‑by‑side on iPad) ───
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.light)

            ContentView()
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.dark)
        }
    }
}

