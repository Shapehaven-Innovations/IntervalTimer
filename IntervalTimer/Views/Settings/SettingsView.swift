//
//  SettingsView.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject    private var themeManager: ThemeManager

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
            .environmentObject(ThemeManager.shared)
    }
}

