// SettingsView.swift
//
//  SettingsView.swift
//  IntervalTimer
//  Modernized Settings: live theme switching + sound selection
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // MARK: – In‑app Appearance override
    @AppStorage("useDarkMode") private var useDarkMode: Bool = false

    // MARK: – Stored settings
    @AppStorage("enableParticles") private var enableParticles: Bool = true

    // MARK: – Data sources
    private let themes = ThemeType.allCases

    // MARK: – Static accent for this screen
    private let accent: Color = .blue

    var body: some View {
        NavigationView {
            Form {
                // ── Appearance ──
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $useDarkMode)
                }

                // ── General ──
                Section(header: Text("General")) {
                    Toggle("Show Particles Behind Tiles", isOn: $enableParticles)
                        .toggleStyle(SwitchToggleStyle(tint: accent))
                }

                // ── App Theme ──
                Section(header: Text("App Theme")) {
                    Picker("", selection: $themeManager.selected) {
                        ForEach(themes) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // ── Sound ── (our dynamic view)
                SoundSettingsView()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .accentColor(accent)
        }
        .preferredColorScheme(useDarkMode ? .dark : .light)
        .interactiveDismissDisabled(false)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")

            SettingsView()
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
#endif

