//
//  ContentView.swift
//  IntervalTimer
//
//  Now with a fully custom header for perfect control of title color.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // The user’s chosen “Screen Background” from Settings:
    @AppStorage("screenBackground") private var backgroundRaw: String = BackgroundOption.white.rawValue
    
    // Shows the Settings sheet:
    @State private var showingSettings = false

    /// Map the stored raw String back to our enum.
    private var screenBackground: BackgroundOption {
        BackgroundOption(rawValue: backgroundRaw) ?? .white
    }

    /// What color should the header text & icon be?
    private var headerColor: Color {
        screenBackground == .black ? .white : .black
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // 1) Fill the full screen (including under the status bar)
                screenBackground.color
                    .ignoresSafeArea()

                // 2) Our vertical stack, pushed beneath the status‐bar safe area
                VStack(spacing: 0) {
                    // ─── CUSTOM HEADER ───
                    HStack {
                        Text("Hello, \(UIDevice.current.name)!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(headerColor)

                        Spacer()

                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(headerColor)
                        }
                    }
                    // Respect the top safe area + add a little padding
                    .padding(.horizontal)
                    .padding(.top, geo.safeAreaInsets.top + 12)

                    // ─── GRID OF TILES ───
                    ScrollView {
                        LazyVGrid(
                            columns: [ .init(.flexible()), .init(.flexible()) ],
                            spacing: 20
                        ) {
                            ConfigTilesView()
                            ActionTilesView()
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                }
            }
            // Present Settings modally
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(themeManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(ThemeManager.shared)
                .previewDisplayName("White BG")

            ContentView()
                .environmentObject(ThemeManager.shared)
                .onAppear {
                    UserDefaults.standard.set(
                        BackgroundOption.black.rawValue,
                        forKey: "screenBackground"
                    )
                }
                .previewDisplayName("Black BG")
        }
    }
}

