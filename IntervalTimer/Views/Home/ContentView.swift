//
//  ContentView.swift
//  IntervalTimer
//
//  Title + grid in one VStack, gear in another—both layered in a ZStack.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @AppStorage("screenBackground") private var backgroundRaw: String = BackgroundOption.white.rawValue
    @State private var showingSettings = false

    private var screenBackground: BackgroundOption {
        BackgroundOption(rawValue: backgroundRaw) ?? .white
    }
    private var headerColor: Color {
        screenBackground == .black ? .white : .black
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ─── 1) Full‑screen background ───
                screenBackground.color
                    .ignoresSafeArea()

                // ─── 2) Main content stack ───
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Hello, \(UIDevice.current.name)!")
                            .font(.largeTitle).bold()
                            .foregroundColor(headerColor)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, geo.safeAreaInsets.top + 12)

                    // Tile grid
                    ScrollView {
                        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())],
                                  spacing: 20) {
                            ConfigTilesView()
                            ActionTilesView()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }

                // ─── 3) Gear button in its own stack ───
                VStack {
                    // pushes content below the notch
                    Spacer().frame(height: geo.safeAreaInsets.top + 8)
                    HStack {
                        Spacer()
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(headerColor)
                        }
                        .padding(.trailing, 12)
                    }
                    Spacer() // fill the rest
                }
                // let this VStack go under the notch too
                .ignoresSafeArea(edges: .top)
            }
            // ─── 4) Settings sheet ───
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(themeManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager.shared)
            .previewLayout(.device)
            .previewDisplayName("Default")
    }
}

