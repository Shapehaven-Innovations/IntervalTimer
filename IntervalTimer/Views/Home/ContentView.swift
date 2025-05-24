//
//  ContentView.swift
//  IntervalTimer
//
//  Created by You on 5/23/25
//  Refactored: live theme updates via ThemeManager.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    @AppStorage("getReadyDuration")    private var _getReadyDuration = 3
    @AppStorage("timerDuration")       private var _timerDuration    = 20
    @AppStorage("restDuration")        private var _restDuration     = 10
    @AppStorage("sets")                private var _sets             = 8
    @AppStorage("lastWorkoutName")     private var lastWorkoutName  = ""
    @AppStorage("savedConfigurations") private var configsData: Data = Data()

    @State private var configs: [SessionRecord] = []
    @State private var activePicker: PickerType?
    @State private var showingTimer        = false
    @State private var showingConfigEditor = false
    @State private var showingWorkoutLog   = false
    @State private var showingIntention    = false
    @State private var showingAnalytics    = false
    @State private var showingSettings     = false
    @State private var animateTiles        = false
    @State private var pulseTarget         = false

    private var name: String { UIDevice.current.name }

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

    private func binding(for type: PickerType) -> Binding<Int> {
        switch type {
        case .getReady:
            return Binding(get: { _getReadyDuration },
                           set: { _getReadyDuration = $0; lastWorkoutName = "" })
        case .rounds:
            return Binding(get: { _sets },
                           set: { _sets = $0; lastWorkoutName = "" })
        case .work:
            return Binding(get: { _timerDuration },
                           set: { _timerDuration = $0; lastWorkoutName = "" })
        case .rest:
            return Binding(get: { _restDuration },
                           set: { _restDuration = $0; lastWorkoutName = "" })
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                FireballBackground()

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()), GridItem(.flexible())
                    ], spacing: 20) {
                        // Get Ready
                        ConfigTileView(
                            icon:  "bolt.fill",
                            label: "Get Ready",
                            value: format(_getReadyDuration),
                            color: themeManager.selected.cardBackgrounds[0]
                        ) { activePicker = .getReady }
                        .animatedTile(index: 0, animate: animateTiles)

                        // Rounds
                        ConfigTileView(
                            icon:  "repeat.circle.fill",
                            label: "Rounds",
                            value: "\(_sets)",
                            color: themeManager.selected.cardBackgrounds[1]
                        ) { activePicker = .rounds }
                        .animatedTile(index: 1, animate: animateTiles)

                        // Work
                        ConfigTileView(
                            icon:  "flame.fill",
                            label: "Work",
                            value: format(_timerDuration),
                            color: themeManager.selected.cardBackgrounds[2]
                        ) { activePicker = .work }
                        .animatedTile(index: 2, animate: animateTiles)

                        // Rest
                        ConfigTileView(
                            icon:  "bed.double.fill",
                            label: "Rest",
                            value: format(_restDuration),
                            color: themeManager.selected.cardBackgrounds[3]
                        ) { activePicker = .rest }
                        .animatedTile(index: 3, animate: animateTiles)

                        // Start Workout
                        Button { showingTimer = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                Text("Start Workout").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(themeManager.selected.cardBackgrounds[4])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shimmer()
                            .shadow(color: themeManager.selected.cardBackgrounds[4].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 4, animate: animateTiles)

                        // Save Workout
                        Button { showingConfigEditor = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                Text("Save Workout").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(themeManager.selected.cardBackgrounds[5])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: themeManager.selected.cardBackgrounds[5].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 5, animate: animateTiles)

                        // Workout Log
                        Button { showingWorkoutLog = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "list.bullet.clipboard.fill")
                                    .font(.largeTitle)
                                Text("Workout Log").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(themeManager.selected.cardBackgrounds[6])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: themeManager.selected.cardBackgrounds[6].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 6, animate: animateTiles)

                        // Intention
                        Button { showingIntention = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "target")
                                    .font(.largeTitle)
                                    .scaleEffect(pulseTarget ? 1.2 : 0.8)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.9)
                                                        .repeatForever(autoreverses: true)) {
                                            pulseTarget.toggle()
                                        }
                                    }
                                Text("Intention").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(themeManager.selected.cardBackgrounds[7])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: themeManager.selected.cardBackgrounds[7].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 7, animate: animateTiles)

                        // Analytics
                        Button { showingAnalytics = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar.doc.horizontal.fill")
                                    .font(.largeTitle)
                                Text("Analytics").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(themeManager.selected.accent)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: themeManager.selected.accent.opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 8, animate: animateTiles)

                        // … your saved configurations buttons …
                    }
                    .padding()
                }
            }
            .navigationTitle("Hello, \(name)!")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                    }
                }
            }
            // MARK: – sheets
            .sheet(item: $activePicker)       { p in PickerSheet(type: p, value: binding(for: p)) }
            .sheet(isPresented: $showingTimer)        { TimerView(workoutName: lastWorkoutName) }
            .sheet(isPresented: $showingConfigEditor) {
                ConfigurationEditorView(
                    timerDuration: _getReadyDuration,
                    restDuration:  _restDuration,
                    sets:          _sets
                ) { newRec in
                    configs.insert(newRec, at: 0)
                    if let d = try? JSONEncoder().encode(configs) {
                        configsData = d
                    }
                    lastWorkoutName = newRec.name
                }
            }
            .sheet(isPresented: $showingWorkoutLog)   { WorkoutLogView() }
            .sheet(isPresented: $showingIntention)    { IntentionsView() }
            .sheet(isPresented: $showingAnalytics)    { AnalyticsView() }
            .sheet(isPresented: $showingSettings)     { SettingsView() }
            .onAppear {
                if let decoded = try? JSONDecoder().decode([SessionRecord].self, from: configsData) {
                    configs = decoded
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateTiles = true
                }
            }
        }
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ThemeManager.shared)
    }
}

