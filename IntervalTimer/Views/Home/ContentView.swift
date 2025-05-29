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
            ZStack {
                // Fill entire screen; status bar & nav‑bar use transparent background
                Color(.systemBackground)
                    .ignoresSafeArea()

                // ─── Your existing tiles grid ───
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 20
                    ) {
                        ConfigTilesView()
                        ActionTilesView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            // ─── Large, system‑drawn title under the Dynamic Island ───
            .navigationTitle("Hello, \(UIDevice.current.name)!")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Gear in top‑right, tinted automatically by UINavigationBar.appearance().tintColor
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
        }
        // Force single‑column style on iPhone
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

