//
//  SettingsView.swift
//  IntervalTimer
//  Modernized Settings: add in‑app Light/Dark toggle
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode

    // MARK: – In‑app Appearance override
    @AppStorage("useDarkMode") private var useDarkMode: Bool = false

    // MARK: – Stored settings
    @AppStorage("enableParticles")    private var enableParticles: Bool   = true
    @AppStorage("selectedTheme")      private var selectedThemeRaw: String = ThemeType.neonPop.rawValue
    @AppStorage("screenBackground")   private var screenBackgroundRaw: String = BackgroundOption.white.rawValue

    // MARK: – Data sources
    private let themes      = ThemeType.allCases
    private let backgrounds = BackgroundOption.allCases

    // MARK: – Static accent for this screen
    private let accent: Color = .blue

    var body: some View {
        NavigationView {
            Form {
                // ── Appearance ──
                Section(header: Text("Settings Appearance")) {
                    Toggle("Dark Mode", isOn: $useDarkMode)
                }

                // ── General ──
                Section(header: Text("General")) {
                    Toggle("Show Particles Behind Tiles", isOn: $enableParticles)
                        .toggleStyle(SwitchToggleStyle(tint: accent))
                }

                // ── App Theme ──
                Section(header: Text("App Theme")) {
                    Picker("", selection: $selectedThemeRaw) {
                        ForEach(themes) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // ── Screen Background ──
                Section(header: Text("Screen Background")) {
                    Picker("", selection: $screenBackgroundRaw) {
                        ForEach(backgrounds) { bg in
                            Text(bg.rawValue).tag(bg.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .tint(accent)
                }
            }
            .accentColor(accent)
        }
        // Apply the chosen scheme to the Settings screen (and propagate if desired)
        .preferredColorScheme(useDarkMode ? .dark : .light)
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

