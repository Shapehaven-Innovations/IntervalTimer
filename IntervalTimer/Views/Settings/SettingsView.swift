// SettingsView.swift
// IntervalTimer
// Updated 05/26/25 to toggle particles instead of fireballs

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject    private var themeManager: ThemeManager

    @AppStorage("screenBackground") private var backgroundRaw: String = BackgroundOption.white.rawValue
    @AppStorage("enableParticles")  private var enableParticles: Bool = true

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

                Section(header: Text("Particles")) {
                    Toggle("Particles Behind Tiles", isOn: $enableParticles)
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
        SettingsView().environmentObject(ThemeManager.shared)
    }
}

