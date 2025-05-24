//
//  SettingsView.swift
//  IntervalTimer
//
//  Created by user on 5/24/25.
//


// SettingsView.swift
// Allows the user to pick from all ThemeType cases

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = ThemeType.colorful.rawValue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Theme")) {
                    Picker("Theme", selection: $selectedThemeRaw) {
                        ForEach(ThemeType.allCases) { theme in
                            Text(theme.rawValue).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing:
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
