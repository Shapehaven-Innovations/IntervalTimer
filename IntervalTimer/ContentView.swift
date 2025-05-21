
// ContentView.swift
// IntervalTimer

import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.presentationMode) private var presentationMode

    // MARK: – User Identity
    private var name: String { UIDevice.current.name }

    // MARK: – Backing storage for AppStorage (to intercept writes)
    @AppStorage("getReadyDuration") private var _getReadyDuration: Int = 3
    @AppStorage("timerDuration")    private var _timerDuration:    Int = 20
    @AppStorage("restDuration")     private var _restDuration:     Int = 10
    @AppStorage("sets")             private var _sets:             Int = 8

    // MARK: – Last workout name
    @AppStorage("lastWorkoutName") private var lastWorkoutName: String = ""

    // MARK: – Computed properties for display
    private var getReadyDuration: Int { _getReadyDuration }
    private var timerDuration:    Int { _timerDuration }
    private var restDuration:     Int { _restDuration }
    private var sets:             Int { _sets }

    // MARK: – Bindings that clear lastWorkoutName on manual change
    private var getReadyBinding: Binding<Int> {
        Binding(get: { _getReadyDuration },
                set: { new in _getReadyDuration = new; lastWorkoutName = "" })
    }
    private var timerBinding: Binding<Int> {
        Binding(get: { _timerDuration },
                set: { new in _timerDuration = new; lastWorkoutName = "" })
    }
    private var restBinding: Binding<Int> {
        Binding(get: { _restDuration },
                set: { new in _restDuration = new; lastWorkoutName = "" })
    }
    private var setsBinding: Binding<Int> {
        Binding(get: { _sets },
                set: { new in _sets = new; lastWorkoutName = "" })
    }

    // MARK: – Saved configurations
    @AppStorage("savedConfigurations") private var configsData: Data = Data()
    @State private var configs: [SessionRecord] = []

    // MARK: – Sheet / Navigation controls
    @State private var activePicker: PickerType?
    @State private var showingConfigEditor = false
    @State private var showingWorkoutLog   = false
    @State private var showingIntention    = false
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
                    // CONFIG TILES
                    tile(icon: "bolt.fill",
                         label: "Get Ready",
                         value: format(getReadyDuration),
                         color: Theme.cardBackgrounds[0]) {
                        activePicker = .getReady
                    }

                    tile(icon: "repeat.circle.fill",
                         label: "Rounds",
                         value: "\(sets)",
                         color: Theme.cardBackgrounds[1]) {
                        activePicker = .rounds
                    }

                    tile(icon: "flame.fill",
                         label: "Work",
                         value: format(timerDuration),
                         color: Theme.cardBackgrounds[2]) {
                        activePicker = .work
                    }

                    tile(icon: "bed.double.fill",
                         label: "Rest",
                         value: format(restDuration),
                         color: Theme.cardBackgrounds[3]) {
                        activePicker = .rest
                    }

                    // ACTION TILES
                    tile(icon: "play.circle.fill",
                         label: "Start Workout",
                         color: Theme.cardBackgrounds[4]) {
                        showingTimer = true
                    }

                    tile(icon: "plus.circle.fill",
                         label: "Save Workout",
                         color: Theme.cardBackgrounds[5]) {
                        showingConfigEditor = true
                    }

                    tile(icon: "list.bullet.clipboard.fill",
                         label: "Workout Log",
                         color: Theme.cardBackgrounds[6]) {
                        showingWorkoutLog = true
                    }

                    tile(icon: "target",
                         label: "Intention",
                         color: Theme.cardBackgrounds[7]) {
                        showingIntention = true
                    }

                    tile(icon: "chart.bar.doc.horizontal.fill",
                         label: "Analytics",
                         color: Theme.accent) {
                        showingAnalytics = true
                    }

                    // SAVED WORKOUTS WITH DELETE CONTEXT MENU
                    ForEach(configs) { record in
                        tile(icon: "slider.horizontal.3",
                             label: record.name,
                             value: "\(format(record.timerDuration)) / \(format(record.restDuration)) / \(record.sets)x",
                             color: .gray) {
                            _timerDuration  = record.timerDuration
                            _restDuration   = record.restDuration
                            _sets           = record.sets
                            lastWorkoutName = record.name
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                if let idx = configs.firstIndex(where: { $0.id == record.id }) {
                                    configs.remove(at: idx)
                                    saveConfigs()
                                }
                            } label: {
                                Label("Delete \"\(record.name)\"", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Hello, \(name)!")
            // PICKER SHEET
            .sheet(item: $activePicker) { picker in
                PickerSheet(
                    type: picker,
                    getReady: getReadyBinding,
                    rounds:   setsBinding,
                    work:     timerBinding,
                    rest:     restBinding
                )
            }
            // TIMER SHEET
            .sheet(isPresented: $showingTimer) {
                TimerView(workoutName: lastWorkoutName)
            }
            // CONFIG EDITOR SHEET
            .sheet(isPresented: $showingConfigEditor) {
                ConfigurationEditorView(
                    timerDuration: getReadyDuration,
                    restDuration:  restDuration,
                    sets:          sets
                ) { newRecord in
                    configs.insert(newRecord, at: 0)
                    saveConfigs()
                    lastWorkoutName = newRecord.name
                }
            }
            .sheet(isPresented: $showingWorkoutLog) { WorkoutLogView() }
            .sheet(isPresented: $showingIntention)    { IntentionsView() }
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
        if let decoded = try? JSONDecoder().decode([SessionRecord].self, from: configsData) {
            configs = decoded
        }
    }

    private func saveConfigs() {
        if let encoded = try? JSONEncoder().encode(configs) {
            configsData = encoded
        }
    }
}

// MARK: – Inline PickerSheet (updated)

struct PickerSheet: View {
    let type: ContentView.PickerType
    @Binding var getReady: Int
    @Binding var rounds:   Int
    @Binding var work:     Int
    @Binding var rest:     Int

    @Environment(\.presentationMode) private var presentationMode

    /// Map each picker to its Theme color
    private var themeColor: Color {
        switch type {
        case .getReady: return Theme.cardBackgrounds[0]
        case .rounds:   return Theme.cardBackgrounds[1]
        case .work:     return Theme.cardBackgrounds[2]
        case .rest:     return Theme.cardBackgrounds[3]
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                themeColor.opacity(0.1)
                    .ignoresSafeArea()

                Form {
                    Section(header:
                        Text(type.title)
                            .font(.headline)
                            .foregroundColor(themeColor)
                    ) {
                        if type == .rounds {
                            Picker("Rounds", selection: $rounds) {
                                ForEach(1...20, id: \.self) {
                                    Text("\($0)").tag($0)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxHeight: 200)
                        } else {
                            Picker("\(type.title) Duration", selection: bindingFor(type)) {
                                ForEach(1...300, id: \.self) {
                                    Text(format($0)).tag($0)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxHeight: 200)
                        }
                    }
                    .listRowBackground(Color(.systemBackground))
                }
                .tint(themeColor)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    // MARK: – Helpers

    private func bindingFor(_ type: ContentView.PickerType) -> Binding<Int> {
        switch type {
        case .getReady: return $getReady
        case .work:     return $work
        case .rest:     return $rest
        case .rounds:   return $rounds
        }
    }

    private func format(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs    = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


