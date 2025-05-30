//
//  ActionTilesView.swift
//  IntervalTimer
//  Updated to fix ambiguous ForEach init
//

import SwiftUI

struct ActionTilesView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // MARK: – Stored settings & saved configs
    @AppStorage("getReadyDuration")    private var getReadyDuration  = 3
    @AppStorage("restDuration")        private var restDuration      = 10
    @AppStorage("sets")                private var sets              = 8
    @AppStorage("lastWorkoutName")     private var lastWorkoutName   = ""
    @AppStorage("savedConfigurations") private var configsData: Data  = Data()

    // MARK: – Local state
    @State private var configs: [SessionRecord] = []

    @State private var showingTimer        = false
    @State private var showingConfigEditor = false
    @State private var showingWorkoutLog   = false
    @State private var showingIntention    = false
    @State private var showingAnalytics    = false

    var body: some View {
        Group {
            // ─── Static action tiles ─────────────────────
            ActionTileView(
                icon:    "play.circle.fill",
                label:   "Start Workout",
                bgColor: themeManager.selected.cardBackgrounds[4],
                index:   4
            ) {
                showingTimer = true
            }

            ActionTileView(
                icon:    "plus.circle.fill",
                label:   "Save Workout",
                bgColor: themeManager.selected.cardBackgrounds[5],
                index:   5
            ) {
                showingConfigEditor = true
            }

            ActionTileView(
                icon:    "list.bullet.clipboard.fill",
                label:   "Workout Log",
                bgColor: themeManager.selected.cardBackgrounds[6],
                index:   6
            ) {
                showingWorkoutLog = true
            }

            ActionTileView(
                icon:    "target",
                label:   "Intention",
                bgColor: themeManager.selected.cardBackgrounds[7],
                index:   7
            ) {
                showingIntention = true
            }

            ActionTileView(
                icon:    "chart.bar.doc.horizontal.fill",
                label:   "Analytics",
                bgColor: themeManager.selected.accent,
                index:   8
            ) {
                showingAnalytics = true
            }

            // ─── Dynamic saved‑configuration tiles ───────
            ForEach(Array(configs.enumerated()), id: \.1.id) { (idx, config) in
                ActionTileView(
                    icon:    "slider.horizontal.3",
                    label:   config.name,
                    bgColor: themeManager.selected.cardBackgrounds[
                                  idx % themeManager.selected.cardBackgrounds.count
                              ],
                    index:   idx + 9
                ) {
                    // Load and start this saved config
                    getReadyDuration = config.timerDuration
                    restDuration      = config.restDuration
                    sets              = config.sets
                    lastWorkoutName   = config.name
                    showingTimer      = true
                }
                .contextMenu {
                    Button(role: .destructive) {
                        // Delete this configuration
                        configs.removeAll { $0.id == config.id }
                        if let data = try? JSONEncoder().encode(configs) {
                            configsData = data
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        // ─── Sheets ───────────────────────────────────
        .sheet(isPresented: $showingTimer) {
            TimerView(workoutName: lastWorkoutName)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingConfigEditor) {
            ConfigurationEditorView(
                timerDuration: getReadyDuration,
                restDuration:  restDuration,
                sets:          sets
            ) { newRec in
                configs.insert(newRec, at: 0)
                if let data = try? JSONEncoder().encode(configs) {
                    configsData = data
                }
                lastWorkoutName = newRec.name
            }
            .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingWorkoutLog) {
            WorkoutLogView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingIntention) {
            IntentionsView { _ in }
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView()
                .environmentObject(themeManager)
        }
        // ─── Load saved configs ───────────────────────
        .onAppear {
            if let decoded = try? JSONDecoder().decode([SessionRecord].self,
                                                       from: configsData) {
                configs = decoded
            }
        }
    }
}

struct ActionTilesView_Previews: PreviewProvider {
    static var previews: some View {
        ActionTilesView()
            .environmentObject(ThemeManager.shared)
    }
}

