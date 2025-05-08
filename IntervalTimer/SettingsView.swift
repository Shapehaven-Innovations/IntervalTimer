// SettingsView.swift
// IntervalTimer
// Create, save, delete, rename & apply customized interval sessions

import SwiftUI

struct SettingsView: View {
    @AppStorage("timerDuration") private var timerDuration: Int = 60
    @AppStorage("restDuration") private var restDuration: Int = 30
    @AppStorage("sets") private var sets: Int = 1
    @AppStorage("weeklyGoal") private var weeklyGoal: Int = 3

    private let configsKey = "savedConfigurations"
    @State private var configs: [SessionRecord] = []
    @State private var showConfigEditor = false
    @State private var renamingRecord: SessionRecord?
    @State private var showingHistory = false

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
                    if configs.isEmpty {
                        Text("No saved configurations.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(configs) { record in
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                Text(record.name)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Apply this config
                                timerDuration = record.timerDuration
                                restDuration  = record.restDuration
                                sets          = record.sets
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    delete(record: record)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    renamingRecord = record
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }

                    Button {
                        showConfigEditor = true
                    } label: {
                        Label("Save Configuration", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: resetSettings) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                AnalyticsView()
            }
            .sheet(isPresented: $showConfigEditor) {
                ConfigurationEditorView(
                    timerDuration: timerDuration,
                    restDuration: restDuration,
                    sets: sets
                ) { newRecord in
                    configs.insert(newRecord, at: 0)
                    saveConfigs()
                }
            }
            .sheet(item: $renamingRecord) { record in
                RenameConfigurationView(currentName: record.name) { newName in
                    if let idx = configs.firstIndex(where: { $0.id == record.id }) {
                        configs[idx].name = newName
                        saveConfigs()
                    }
                }
            }
            .onAppear(perform: loadConfigs)
        }
    }

    private func resetSettings() {
        timerDuration = 60
        restDuration   = 30
        sets           = 1
        weeklyGoal     = 3
    }

    private func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: configsKey),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            configs = decoded.sorted { $0.date > $1.date }
        } else {
            configs = []
        }
    }

    private func saveConfigs() {
        if let encoded = try? JSONEncoder().encode(configs) {
            UserDefaults.standard.set(encoded, forKey: configsKey)
        }
    }

    private func delete(record: SessionRecord) {
        if let idx = configs.firstIndex(where: { $0.id == record.id }) {
            configs.remove(at: idx)
            saveConfigs()
        }
    }
}

