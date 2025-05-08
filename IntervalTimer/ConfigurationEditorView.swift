// ConfigurationEditorView.swift
// IntervalTimer
// Sheet for creating a new custom configuration

import SwiftUI

struct ConfigurationEditorView: View {
    @Environment(\.presentationMode) private var presentationMode
    let timerDuration: Int
    let restDuration: Int
    let sets: Int
    @State private var name: String = ""
    let onSave: (SessionRecord) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration Name")) {
                    TextField("Enter a name", text: $name)
                }
                Section(header: Text("Settings Preview")) {
                    HStack { Text("Work"); Spacer(); Text("\(timerDuration) sec") }
                    HStack { Text("Rest"); Spacer(); Text("\(restDuration) sec") }
                    HStack { Text("Sets"); Spacer(); Text("\(sets)") }
                }
            }
            .navigationTitle("New Configuration")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let trimmed = name.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    let record = SessionRecord(
                        name: trimmed,
                        date: Date(),
                        timerDuration: timerDuration,
                        restDuration: restDuration,
                        sets: sets
                    )
                    onSave(record)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
