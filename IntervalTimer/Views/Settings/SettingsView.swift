//
//  SettingsView.swift
//  IntervalTimer
//  Updated 05/27/25 to hide default picker labels
//

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
                // MARK: App Theme
                Section(header: Text("App Theme")) {
                    Picker("", selection: $themeManager.selected) {
                        ForEach(ThemeType.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // MARK: Screen Background
                Section(header: Text("Screen Background")) {
                    Picker("", selection: backgroundBinding) {
                        ForEach(BackgroundOption.allCases) { bg in
                            Text(bg.rawValue).tag(bg)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // MARK: Particles Toggle
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
        SettingsView()
            .environmentObject(ThemeManager.shared)
    }
}

