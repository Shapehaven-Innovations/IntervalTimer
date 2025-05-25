//
//  SettingsView.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//  Updated on 5/25/25 to let the user pick screen background and toggle fireballs.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject    private var themeManager: ThemeManager

    /// Persist the user’s background choice as a raw string.
    @AppStorage("screenBackground") private var backgroundRaw: String = BackgroundOption.white.rawValue

    /// Toggle for fireballs behind the tiles.
    @AppStorage("enableFireballs") private var enableFireballs: Bool = true

    /// A Binding<BackgroundOption> so we can drive a Picker directly.
    private var backgroundBinding: Binding<BackgroundOption> {
        Binding(
            get: { BackgroundOption(rawValue: backgroundRaw) ?? .white },
            set: { backgroundRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Theme")) {
                    Picker("Theme", selection: $themeManager.selected) {
                        ForEach(ThemeType.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text("Screen Background")) {
                    Picker("Background", selection: backgroundBinding) {
                        ForEach(BackgroundOption.allCases) { bg in
                            Text(bg.rawValue).tag(bg)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text("Fireballs")) {
                    Toggle("Fireballs Behind Tiles", isOn: $enableFireballs)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing:
                Button("Done") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager.shared)
    }
}

