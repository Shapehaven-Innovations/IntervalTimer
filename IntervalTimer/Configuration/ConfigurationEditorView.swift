// ConfigurationEditorView.swift
// IntervalTimer
// Sheet for creating a new custom configuration

import SwiftUI

struct ConfigurationEditorView: View {
    @Environment(\.presentationMode) private var presentationMode

    // Inputs from ContentView
    let timerDuration: Int
    let restDuration: Int
    let sets:          Int
    let onSave:       (SessionRecord) -> Void

    // Local state
    @State private var name: String = ""

    // use the same “Save Workout” tile color (index 5) as our theme
    private let themeColor = Theme.cardBackgrounds[5]

    var body: some View {
        NavigationView {
            ZStack {
                // Light background wash
                themeColor.opacity(0.1)
                    .ignoresSafeArea()

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
                .tint(themeColor)                    // tint pickers & buttons
                .scrollContentBackground(.hidden)    // remove default gray
            }
            .navigationTitle("New Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveConfiguration()
                }
            )
        }
    }

    private func saveConfiguration() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let record = SessionRecord(
            name:           trimmed,
            date:           Date(),
            timerDuration:  timerDuration,
            restDuration:   restDuration,
            sets:           sets
        )
        onSave(record)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ConfigurationEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationEditorView(
            timerDuration: 20,
            restDuration:  10,
            sets:          5
        ) { _ in }
    }
}

