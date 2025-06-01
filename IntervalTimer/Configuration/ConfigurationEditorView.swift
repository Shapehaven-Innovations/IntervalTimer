/// ConfigurationEditorView.swift
//
//  ConfigurationEditorView.swift
//  IntervalTimer
//
//  Created by user on 5/23/25.
//

import SwiftUI

struct ConfigurationEditorView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject    private var themeManager: ThemeManager

    // Inputs from ContentView
    let timerDuration: Int
    let restDuration:  Int
    let sets:           Int
    let onSave:        (SessionRecord) -> Void

    // Local state
    @State private var name: String = ""

    /// Use the “Save Workout” tile color (index 5) from the current theme.
    private var themeColor: Color {
        themeManager.selected.cardBackgrounds[5]
    }

    var body: some View {
        NavigationView {
            ZStack {
                themeColor.opacity(0.1).ignoresSafeArea()

                Form {
                    Section(header:
                        Text("Configuration Name")
                            .font(.headline)
                            .foregroundColor(themeColor)
                    ) {
                        TextField("Enter a name", text: $name)
                            .autocapitalization(.words)
                    }

                    Section(header:
                        Text("Settings Preview")
                            .font(.headline)
                            .foregroundColor(themeColor)
                    ) {
                        HStack {
                            Text("Work")
                            Spacer()
                            Text("\(timerDuration) sec")
                        }
                        HStack {
                            Text("Rest")
                            Spacer()
                            Text("\(restDuration) sec")
                        }
                        HStack {
                            Text("Sets")
                            Spacer()
                            Text("\(sets)")
                        }
                    }
                }
                .tint(themeColor)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save")   { saveConfiguration() }
            )
        }
    }

    private func saveConfiguration() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let record = SessionRecord(
            name:          trimmed,
            date:          Date(),
            timerDuration: timerDuration,
            restDuration:  restDuration,
            sets:          sets
        )
        onSave(record)
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
struct ConfigurationEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationEditorView(
            timerDuration: 20,
            restDuration:  10,
            sets:          5
        ) { _ in }
        .environmentObject(ThemeManager.shared)
    }
}
#endif

