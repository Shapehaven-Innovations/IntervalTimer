// ContentView.swift
// IntervalTimer
// Restored all tiles & functionality, broken into small sub‑views to avoid compiler timeouts

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @AppStorage("screenBackground") private var backgroundRaw: String = BackgroundOption.white.rawValue
    @State private var showingSettings = false

    private var screenBackground: BackgroundOption {
        BackgroundOption(rawValue: backgroundRaw) ?? .white
    }

    var body: some View {
        NavigationView {
            ZStack {
                screenBackground.color.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(
                        columns: [ .init(.flexible()), .init(.flexible()) ],
                        spacing: 20
                    ) {
                        ConfigTilesView()   // your new 4‑tile subview
                        ActionTilesView()   // your new 5‑tile subview
                    }
                    .padding()
                }
            }
            .navigationTitle("Hello, \(UIDevice.current.name)!")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
          .environmentObject(ThemeManager.shared)
    }
}
