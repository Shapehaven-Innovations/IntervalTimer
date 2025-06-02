// ActionTilesView.swift
// IntervalTimer
// Updated 06/02/25 so that tapping a “preconfigured template” writes its work/rest/sets
// directly into the @AppStorage keys that TimerView reads (timerDuration, restDuration, sets).

import SwiftUI

struct ActionTilesView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    // ─── AppStorage keys for user‑configurable durations & saved config data ───
    @AppStorage("getReadyDuration")    private var getReadyDuration: Int   = 3
    @AppStorage("timerDuration")       private var timerDuration: Int      = 20
    @AppStorage("restDuration")        private var restDuration: Int       = 10
    @AppStorage("sets")                private var sets: Int               = 8
    @AppStorage("lastWorkoutName")     private var lastWorkoutName: String = ""
    @AppStorage("savedConfigurations") private var configsData: Data       = Data()

    /// Whether built‑in/preconfigured templates should be shown
    @AppStorage("showPreconfiguredTemplates") private var showPreconfiguredTemplates: Bool = true

    /// Underlying Data blob that stores the JSON‑encoded [UUID] of deleted built‑ins
    @AppStorage("deletedPreconfiguredTemplates") private var deletedPreconfiguredTemplatesData: Data = Data()

    // ─── Local state for user‑saved (custom) configurations ───
    @State private var customConfigs: [SessionRecord] = []

    // ─── Which sheet is currently presented ───
    @State private var showingTimer        = false
    @State private var showingConfigEditor = false
    @State private var showingWorkoutLog   = false
    @State private var showingIntention    = false
    @State private var showingAnalytics    = false

    // ─────────────────────────────────────────────────
    // Combine “built‑in” templates + user‑saved configurations
    // ─────────────────────────────────────────────────
    private var displayedConfigs: [SessionRecord] {
        var result: [SessionRecord] = []

        // 1) If toggled ON, add all built‑in templates except those the user has deleted:
        if showPreconfiguredTemplates {
            let builtIns = PreconfiguredTemplates.all.filter { !loadDeletedIDs().contains($0.id) }
            result.append(contentsOf: builtIns)
        }

        // 2) Then append any user‑saved custom configurations:
        result.append(contentsOf: customConfigs)
        return result
    }

    var body: some View {
        Group {
            // ─── Static “Action” tiles (Start/Save/Log/Intention/Analytics) ───
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

            // ─── ForEach over “built‑in + custom” configurations ───
            ForEach(Array(displayedConfigs.enumerated()), id: \.1.id) { idx, config in
                ActionTileView(
                    icon:    "slider.horizontal.3",
                    label:   config.name,
                    bgColor: themeManager.selected.cardBackgrounds[
                                  idx % themeManager.selected.cardBackgrounds.count
                              ],
                    index:   idx + 9
                ) {
                    // When tapped, write the built‑in or custom values into @AppStorage so
                    // that TimerView picks them up:
                    timerDuration    = config.timerDuration
                    restDuration     = config.restDuration
                    sets             = config.sets
                    lastWorkoutName  = config.name
                    showingTimer     = true
                }
                .contextMenu {
                    Button(role: .destructive) {
                        delete(record: config)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        // ─── Present the various sheets ────────────────────────────────────
        .sheet(isPresented: $showingTimer) {
            TimerView(workoutName: lastWorkoutName)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingConfigEditor) {
            ConfigurationEditorView(
                timerDuration: timerDuration,
                restDuration:  restDuration,
                sets:          sets
            ) { newRec in
                customConfigs.insert(newRec, at: 0)
                persistCustomConfigs()
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
        // ─── Load custom configs on appear ────────────────────────────────────
        .onAppear {
            loadCustomConfigs()
        }
    }

    // MARK: — Load & Persist Custom (User‐Saved) Configurations

    private func loadCustomConfigs() {
        if let decoded = try? JSONDecoder().decode([SessionRecord].self, from: configsData) {
            customConfigs = decoded
        } else {
            customConfigs = []
        }
    }

    private func persistCustomConfigs() {
        if let data = try? JSONEncoder().encode(customConfigs) {
            configsData = data
        }
    }

    // MARK: — Load & Persist Deleted Built‑In UUIDs

    /// Decode Data → [UUID] → Set<UUID>
    private func loadDeletedIDs() -> Set<UUID> {
        guard let array = try? JSONDecoder()
                .decode([UUID].self, from: deletedPreconfiguredTemplatesData) else {
            return Set()
        }
        return Set(array)
    }

    /// Encode Set<UUID> → [UUID] → Data
    private func saveDeletedIDs(_ set: Set<UUID>) {
        let array = Array(set)
        if let data = try? JSONEncoder().encode(array) {
            deletedPreconfiguredTemplatesData = data
        }
    }

    // MARK: — Deletion Logic

    /// If `record.id` is one of the built‑in templates’ UUIDs, add it to the deleted set.
    /// Otherwise, remove it from the user‑saved array.
    private func delete(record: SessionRecord) {
        if PreconfiguredTemplates.byID.keys.contains(record.id) {
            // Built‑in ⇒ add to “deleted” set
            var current = loadDeletedIDs()
            current.insert(record.id)
            saveDeletedIDs(current)
        } else {
            // Custom user configuration ⇒ remove from customConfigs
            customConfigs.removeAll { $0.id == record.id }
            persistCustomConfigs()
        }
    }
}

struct ActionTilesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActionTilesView()
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.light)

            ActionTilesView()
                .environmentObject(ThemeManager.shared)
                .preferredColorScheme(.dark)
        }
    }
}

