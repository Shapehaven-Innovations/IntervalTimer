// SettingsView.swift
// IntervalTimer
// Create, rename, and save customized interval sessions
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("timerDuration") private var timerDuration: Int = 60
    @AppStorage("restDuration") private var restDuration: Int = 30
    @AppStorage("sets") private var sets: Int = 1
    @AppStorage("weeklyGoal") private var weeklyGoal: Int = 3

    @State private var showingHistory = false
    @State private var history: [SessionRecord] = []
    @State private var showConfigEditor = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interval Configuration").font(.headline)) {
                    Stepper(value: $timerDuration, in: 10...3600, step: 5) {
                        Text("Work: \(timerDuration) sec")
                    }
                    Stepper(value: $restDuration, in: 10...600, step: 5) {
                        Text("Rest: \(restDuration) sec")
                    }
                    Stepper(value: $sets, in: 1...20, step: 1) {
                        Text("Sets: \(sets)")
                    }
                }

                Section(header: Text("Goals").font(.headline)) {
                    Stepper(value: $weeklyGoal, in: 1...14) {
                        Text("Weekly Sessions Goal: \(weeklyGoal)")
                    }
                    Text("Complete at least \(weeklyGoal) workout sessions per week.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Accessibility & Analytics").font(.headline)) {
                    HStack {
                        Image(systemName: "figure.wave")
                            .font(.title2)
                        Text("Enhanced accessibility")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    Text("Improves readability by increasing text size and contrast.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Button {
                        showingHistory = true
                    } label: {
                        Label("View Session Analytics", systemImage: "chart.bar.doc.horizontal")
                    }
                }

                Section(header: Text("Saved Configurations").font(.headline)) {
                    if history.isEmpty {
                        Text("No saved configurations.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach($history) { $record in
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                TextField("Name", text: $record.name, onCommit: saveHistory)
                            }
                        }
                        .onDelete(perform: deleteConfigs)
                    }

                    Button {
                        showConfigEditor = true
                    } label: {
                        Label("Save Current Configuration", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button(action: resetSettings) {
                Image(systemName: "arrow.clockwise")
            })
            // Analytics sheet
            .sheet(isPresented: $showingHistory) {
                AnalyticsView()
            }
            // Editor sheet for new config
            .sheet(isPresented: $showConfigEditor) {
                ConfigurationEditorView(
                    timerDuration: timerDuration,
                    restDuration: restDuration,
                    sets: sets
                ) { newRecord in
                    history.insert(newRecord, at: 0)
                    saveHistory()
                }
            }
            .onAppear(perform: loadHistory)
        }
    }

    private func resetSettings() {
        timerDuration = 60
        restDuration   = 30
        sets           = 1
        weeklyGoal     = 3
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        } else {
            history = []
        }
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "sessionHistory")
        }
    }

    private func deleteConfigs(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }
}

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
                    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    let record = SessionRecord(
                        name: name,
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

