// ContentView.swift
// IntervalTimer
// Restored all tiles & functionality, broken into small sub‑views to avoid compiler timeouts

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // MARK: – Workout configuration storage
    @AppStorage("getReadyDuration")    private var getReadyDuration = 3
    @AppStorage("timerDuration")       private var timerDuration    = 20
    @AppStorage("restDuration")        private var restDuration     = 10
    @AppStorage("sets")                private var sets             = 8
    @AppStorage("lastWorkoutName")     private var lastWorkoutName  = ""
    @AppStorage("savedConfigurations") private var configsData: Data = Data()

    // MARK: – App settings
    @AppStorage("screenBackground") private var backgroundRaw: String = BackgroundOption.white.rawValue
    @AppStorage("enableParticles")  private var enableParticles: Bool = true

    private var screenBackground: BackgroundOption {
        BackgroundOption(rawValue: backgroundRaw) ?? .white
    }

    // MARK: – Local state
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

    private var deviceName: String { UIDevice.current.name }

    // MARK: – PickerType
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
            return Binding(
                get: { getReadyDuration },
                set: { getReadyDuration = $0; lastWorkoutName = "" }
            )
        case .rounds:
            return Binding(
                get: { sets },
                set: { sets = $0; lastWorkoutName = "" }
            )
        case .work:
            return Binding(
                get: { timerDuration },
                set: { timerDuration = $0; lastWorkoutName = "" }
            )
        case .rest:
            return Binding(
                get: { restDuration },
                set: { restDuration = $0; lastWorkoutName = "" }
            )
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                screenBackground.color.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(
                        columns: [ .init(.flexible()), .init(.flexible()) ],
                        spacing: 20
                    ) {
                        getReadyTile
                        roundsTile
                        workTile
                        restTile

                        startWorkoutTile
                        saveWorkoutTile
                        workoutLogTile
                        intentionTile
                        analyticsTile
                    }
                    .padding()
                }
            }
            .navigationTitle("Hello, \(deviceName)!")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(item: $activePicker) { p in
                PickerSheet(type: p, value: binding(for: p))
            }
            .sheet(isPresented: $showingTimer)        { TimerView(workoutName: lastWorkoutName) }
            .sheet(isPresented: $showingConfigEditor) {
                ConfigurationEditorView(
                    timerDuration: getReadyDuration,
                    restDuration:  restDuration,
                    sets:          sets
                ) { newRec in
                    configs.insert(newRec, at: 0)
                    if let d = try? JSONEncoder().encode(configs) {
                        configsData = d
                    }
                    lastWorkoutName = newRec.name
                }
            }
            .sheet(isPresented: $showingWorkoutLog)  { WorkoutLogView() }
            .sheet(isPresented: $showingIntention)   { IntentionsView() }
            .sheet(isPresented: $showingAnalytics)   { AnalyticsView() }
            .sheet(isPresented: $showingSettings)    { SettingsView() }
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

    // MARK: – Upper Tiles

    private var getReadyTile: some View {
        ConfigTileView(
            icon:  "bolt.fill",
            label: "Get Ready",
            value: format(getReadyDuration),
            color: themeManager.selected.cardBackgrounds[0]
        ) { activePicker = .getReady }
        .animatedTile(index: 0, animate: animateTiles)
    }

    private var roundsTile: some View {
        ConfigTileView(
            icon:  "repeat.circle.fill",
            label: "Rounds",
            value: "\(sets)",
            color: themeManager.selected.cardBackgrounds[1]
        ) { activePicker = .rounds }
        .animatedTile(index: 1, animate: animateTiles)
    }

    private var workTile: some View {
        ConfigTileView(
            icon:  "flame.fill",
            label: "Work",
            value: format(timerDuration),
            color: themeManager.selected.cardBackgrounds[2]
        ) { activePicker = .work }
        .animatedTile(index: 2, animate: animateTiles)
    }

    private var restTile: some View {
        ConfigTileView(
            icon:  "bed.double.fill",
            label: "Rest",
            value: format(restDuration),
            color: themeManager.selected.cardBackgrounds[3]
        ) { activePicker = .rest }
        .animatedTile(index: 3, animate: animateTiles)
    }

    // MARK: – Lower Tiles

    private func makeActionTile(
        icon: String,
        label: String,
        bgColor: Color,
        index: Int,
        action: @escaping ()->Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                if enableParticles {
                    ParticleBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                RoundedRectangle(cornerRadius: 16)
                    .fill(bgColor.opacity(0.6))
                VStack(spacing: 8) {
                    Image(systemName: icon).font(.largeTitle)
                    Text(label).font(.headline)
                }
                .foregroundColor(.white)
            }
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .shadow(color: bgColor.opacity(0.3), radius: 6, x: 0, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
        .animatedTile(index: index, animate: animateTiles)
    }

    private var startWorkoutTile: some View {
        makeActionTile(
            icon:   "play.circle.fill",
            label:  "Start Workout",
            bgColor: themeManager.selected.cardBackgrounds[4],
            index:  4
        ) { showingTimer = true }
    }

    private var saveWorkoutTile: some View {
        makeActionTile(
            icon:   "plus.circle.fill",
            label:  "Save Workout",
            bgColor: themeManager.selected.cardBackgrounds[5],
            index:  5
        ) { showingConfigEditor = true }
    }

    private var workoutLogTile: some View {
        makeActionTile(
            icon:   "list.bullet.clipboard.fill",
            label:  "Workout Log",
            bgColor: themeManager.selected.cardBackgrounds[6],
            index:  6
        ) { showingWorkoutLog = true }
    }

    private var intentionTile: some View {
        Button { showingIntention = true } label: {
            ZStack {
                if enableParticles {
                    ParticleBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.selected.cardBackgrounds[7].opacity(0.6))
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.largeTitle)
                        .scaleEffect(pulseTarget ? 1.2 : 0.8)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                                pulseTarget.toggle()
                            }
                        }
                    Text("Intention").font(.headline)
                }
                .foregroundColor(.white)
            }
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .shadow(color: themeManager.selected.cardBackgrounds[7].opacity(0.3), radius: 6, x: 0, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
        .animatedTile(index: 7, animate: animateTiles)
    }

    private var analyticsTile: some View {
        makeActionTile(
            icon:   "chart.bar.doc.horizontal.fill",
            label:  "Analytics",
            bgColor: themeManager.selected.accent,
            index:  8
        ) { showingAnalytics = true }
    }

    // MARK: – Formatting

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

