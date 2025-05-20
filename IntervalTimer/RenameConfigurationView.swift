// RenameConfigurationView.swift
// IntervalTimer
// Sheet for renaming an existing configuration

import SwiftUI

struct RenameConfigurationView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var name: String
    let onRename: (String) -> Void

    init(currentName: String, onRename: @escaping (String) -> Void) {
        _name = State(initialValue: currentName)
        self.onRename = onRename
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration Name")) {
                    TextField("Enter a name", text: $name)
                }
            }
            .navigationTitle("Edit Configuration")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let trimmed = name.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    onRename(trimmed)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

