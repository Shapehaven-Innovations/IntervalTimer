// ContentView.swift
// IntervalTimer
// Main dashboard with config + action tiles

import SwiftUI
import UIKit   // for UIDevice.current.name

struct ContentView: View {
    @Environment(\.presentationMode) private var presentationMode

    // MARK: – Device Info
    private var deviceName: String {
        UIDevice.current.name
    }

    // MARK: – Live settings
    @AppStorage("getReadyDuration") private var getReadyDuration: Int = 3
    @AppStorage("timerDuration")    private var timerDuration:    Int = 20
    @AppStorage("restDuration")     private var restDuration:     Int = 10
    @AppStorage("sets")             private var sets:             Int = 8

    // MARK: – Saved configurations
    @AppStorage("savedConfigurations") private var configsData: Data = Data()
    @State private var configs: [SessionRecord] = []

    // MARK: – Sheet / Navigation controls
    @State private var activePicker: PickerType?
    @State private var showingConfigEditor = false
    @State private var showingWorkoutLog   = false
    @State private var showingGoals        = false
    @State private var showingAnalytics    = false
    @State private var showingTimer        = false

    enum PickerType: Int, Identifiable {
        case getReady, rounds, work, rest
        var id: Int { rawValue }
        var title: String {
            switch self {
            case .getReady: return "Get Ready"
            case .rounds:   return "Rounds"
            case .work:     return "Work"
            case .rest:     return "Rest"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 20
                ) {
                    // — CONFIG TILES —
                    tile(icon: "bolt.fill",
                         label: "Get Ready",
                         value: format(getReadyDuration),
                         color: .yellow) {
                        activePicker = .getReady
                    }

                    tile(icon: "repeat.circle.fill",
                         label: "Rounds",
                         value: "\(sets)",
                         color: .mint) {
                        activePicker = .rounds
                    }

                    tile(icon: "flame.fill",
                         label: "Work",
                         value: format(timerDuration),
                         color: .green) {
                        activePicker = .work
                    }

                    tile(icon: "bed.double.fill",
                         label: "Rest",
                         value: format(restDuration),
                         color: .red) {
                        activePicker = .rest
                    }

                    // — ACTION TILES —
                    tile(icon: "play.circle.fill",
                         label: "Start Workout",
                         color: .orange) {
                        showingTimer = true
                    }

                    tile(icon: "plus.circle.fill",
                         label: "Save Workout",
                         color: .teal) {
                        showingConfigEditor = true
                    }

                    tile(icon: "list.bullet.clipboard.fill",
                         label: "Workout Log",
                         color: .indigo) {
                        showingWorkoutLog = true
                    }

                    tile(icon: "target",
                         label: "Goals",
                         color: .pink) {
                        showingGoals = true
                    }

                    tile(icon: "chart.bar.doc.horizontal.fill",
                         label: "Analytics",
                         color: .blue) {
                        showingAnalytics = true
                    }

                    // — SAVED WORKOUTS —
                    ForEach(configs) { record in
                        tile(icon: "slider.horizontal.3",
                             label: record.name,
                             value: "\(format(record.timerDuration)) / \(format(record.restDuration)) / \(record.sets)x",
                             color: .gray) {
                            timerDuration = record.timerDuration
                            restDuration  = record.restDuration
                            sets          = record.sets
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Hello, \(deviceName)!")
            // .navigationBarItems(trailing: Button("Done") {
            //     presentationMode.wrappedValue.dismiss()
            // })
            // — PICKER SHEET —
            .sheet(item: $activePicker) { picker in
                PickerSheet(
                    type: picker,
                    getReady: $getReadyDuration,
                    rounds:   $sets,
                    work:     $timerDuration,
                    rest:     $restDuration
                )
            }
            // — OTHER SHEETS —
            .sheet(isPresented: $showingTimer) {
                TimerView()
            }
            .sheet(isPresented: $showingConfigEditor) {
                ConfigurationEditorView(
                    timerDuration: timerDuration,
                    restDuration:  restDuration,
                    sets:          sets
                ) { newRecord in
                    configs.insert(newRecord, at: 0)
                    saveConfigs()
                }
            }
            .sheet(isPresented: $showingWorkoutLog) { WorkoutLogView() }
            .sheet(isPresented: $showingGoals)        { IntentionsView() }
            .sheet(isPresented: $showingAnalytics)    { AnalyticsView() }
            .onAppear(perform: loadConfigs)
        }
    }

    // MARK: – Helpers

    private func tile(icon: String,
                      label: String,
                      value: String? = nil,
                      color: Color,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.largeTitle)
                Text(label).font(.headline)
                if let v = value {
                    Text(v).font(.subheadline).bold()
                }
            }
            .foregroundColor(.white)
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 5)
        }
        .accessibilityElement(children: .combine)
    }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func loadConfigs() {
        if let decoded = try? JSONDecoder()
            .decode([SessionRecord].self, from: configsData) {
            configs = decoded
        }
    }

    private func saveConfigs() {
        if let encoded = try? JSONEncoder().encode(configs) {
            configsData = encoded
        }
    }
}

// MARK: – Inline PickerSheet (unchanged)
struct PickerSheet: View {
    let type: ContentView.PickerType
    @Binding var getReady: Int
    @Binding var rounds:   Int
    @Binding var work:     Int
    @Binding var rest:     Int

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(type.title)) {
                    if type == .rounds {
                        Picker("Rounds", selection: $rounds) {
                            ForEach(1...20, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(WheelPickerStyle())
                    } else {
                        Picker("\(type.title) Duration", selection: bindingFor(type)) {
                            ForEach(1...300, id: \.self) { Text(format($0)).tag($0) }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                }
            }
            .navigationTitle(type.title)
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save")   { presentationMode.wrappedValue.dismiss() }
            )
        }
    }

    private func bindingFor(_ type: ContentView.PickerType) -> Binding<Int> {
        switch type {
        case .getReady: return $getReady
        case .work:     return $work
        case .rest:     return $rest
        case .rounds:   return $rounds
        }
    }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

