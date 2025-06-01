// TimerView.swift
//
//  TimerView.swift
//  IntervalTimer
//  Core timer UI + In‑view IntentionBanner + persistence
//
//  Refactored 06/01/25 to load sounds dynamically from mySounds/.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    /// Passed in from ContentView
    let workoutName: String

    // MARK: – User‑configurable settings
    @AppStorage("getReadyDuration") private var getReadyDuration: Int = 3
    @AppStorage("timerDuration")    private var timerDuration:    Int = 60
    @AppStorage("restDuration")     private var restDuration:     Int = 30
    @AppStorage("sets")             private var sets:             Int = 1

    // MARK: – Sound settings
    @AppStorage("enableSound")      private var enableSound: Bool      = true
    @AppStorage("workSound")        private var workSoundRaw: String    = ""
    @AppStorage("restSound")        private var restSoundRaw: String    = ""
    @AppStorage("completeSound")    private var completeSoundRaw: String = ""

    // MARK: – Timer phases
    private enum Phase { case getReady, work, rest, complete }
    @State private var phase:      Phase = .getReady
    @State private var currentTime: Int  = 0
    @State private var currentSet:  Int  = 1
    @State private var timer:      Timer?

    // MARK: – Banner & Intention
    @State private var showBanner:     Bool    = true
    @State private var showIntentions: Bool    = false
    @State private var currentIntention: String? = nil

    // MARK: – Post‑workout summary
    @State private var showSummary: Bool = false
    @State private var justCompletedRecord: SessionRecord? = nil
    @State private var justCompletedCalories: Int = 0

    // MARK: – Computed
    private var totalDuration: Int {
        switch phase {
        case .getReady: return getReadyDuration
        case .work:     return timerDuration
        case .rest:     return restDuration
        case .complete: return 1
        }
    }
    private var elapsedTime: Int { totalDuration - currentTime }

    // MARK: – Dynamic background
    private var backgroundColor: Color {
        let p = themeManager.selected.cardBackgrounds
        switch phase {
        case .getReady: return p[0]
        case .work:     return p[2]
        case .rest:     return p[3]
        case .complete: return p[5]
        }
    }

    // MARK: – Controls style
    private let controlBG = Color.white.opacity(0.3)
    private let controlFG = Color.white

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    if showBanner {
                        IntentionBanner(
                            onTap:     { showIntentions = true },
                            onDismiss: { showBanner = false }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    Spacer()

                    Text(formatTime(currentTime))
                        .font(.system(
                            size: geo.size.width > geo.size.height ? 120 : 100,
                            weight: .bold,
                            design: .monospaced
                        ))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))

                    Spacer()

                    ProgressView(
                        value: phase == .getReady ? 0 : Double(elapsedTime),
                        total: Double(totalDuration)
                    )
                    .progressViewStyle(.linear)
                    .scaleEffect(x: 1, y: 4)
                    .padding(.horizontal)
                    .opacity(phase == .getReady ? 0 : 1)

                    Spacer()

                    HStack(spacing: 40) {
                        Button(action: toggleTimer) {
                            ZStack {
                                Circle().fill(controlBG).frame(width: 80, height: 80)
                                Image(systemName: isRunning
                                      ? "pause.circle.fill"
                                      : "play.circle.fill")
                                    .resizable().frame(width: 60, height: 60)
                                    .foregroundColor(controlFG)
                            }
                        }

                        Button(action: resetAll) {
                            ZStack {
                                Circle().fill(controlBG).frame(width: 80, height: 80)
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .resizable().frame(width: 60, height: 60)
                                    .foregroundColor(controlFG)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(minHeight: geo.size.height)
            }
            .onAppear {
                phase = .getReady
                currentTime = getReadyDuration
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .sheet(isPresented: $showIntentions) {
                IntentionsView { state in
                    currentIntention = state
                    showBanner = false
                }
                .environmentObject(themeManager)
            }
            .sheet(isPresented: $showSummary) {
                if let completed = justCompletedRecord {
                    WorkoutSummaryView(record: completed, calories: justCompletedCalories)
                        .environmentObject(themeManager)
                }
            }
        }
    }

    // MARK: – Helpers

    private var isRunning: Bool { timer != nil }

    private var subtitle: String {
        switch phase {
        case .getReady: return "Get Ready..."
        case .work:     return "Set \(currentSet) of \(sets)"
        case .rest:     return "Rest Time"
        case .complete: return "Great Work!"
        }
    }

    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
        } else {
            startTimerLoop()
        }
    }

    private func startTimerLoop() {
        timer?.invalidate()
        let t = Timer(timeInterval: 1, repeats: true) { _ in
            guard currentTime > 0 else {
                advancePhase()
                return
            }
            currentTime -= 1
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
    }

    private func advancePhase() {
        timer?.invalidate()
        timer = nil

        switch phase {
        case .getReady:
            phase = .work
            currentTime = timerDuration
            playPhaseSound(for: .work)
            startTimerLoop()

        case .work:
            if currentSet < sets {
                phase = .rest
                currentTime = restDuration
                playPhaseSound(for: .rest)
                startTimerLoop()
            } else {
                phase = .complete
                currentTime = 0
                playPhaseSound(for: .complete)
                completeAndSave()
            }

        case .rest:
            currentSet += 1
            phase = .work
            currentTime = timerDuration
            playPhaseSound(for: .work)
            startTimerLoop()

        case .complete:
            // do nothing; summary sheet will appear
            break
        }
    }

    private func resetAll() {
        timer?.invalidate()
        timer = nil
        currentSet = 1
        phase = .getReady
        currentTime = getReadyDuration
    }

    /// Called once the workout is truly complete: save to UserDefaults,
    /// compute calories, then show the summary.
    private func completeAndSave() {
        // 1) Load existing history
        var history = (try? JSONDecoder().decode([SessionRecord].self,
                         from: UserDefaults.standard.data(forKey: "sessionHistory") ?? Data()))
                      ?? []

        // 2) Create the new record
        let newRecord = SessionRecord(
            name:           workoutName,
            date:           Date(),
            timerDuration:  timerDuration,
            restDuration:   restDuration,
            sets:           sets,
            intention:      currentIntention
        )
        history.append(newRecord)

        // 3) Persist
        if let enc = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(enc, forKey: "sessionHistory")
        }

        // 4) Compute calories
        let workSeconds = newRecord.timerDuration * newRecord.sets
        let minutes     = Double(workSeconds) / 60.0
        let wUnit       = UserDefaults.standard.string(forKey: "weightUnit") ?? "kg"
        let wValue      = UserDefaults.standard.integer(forKey: "userWeight")
        let weightKg    = wUnit == "lbs" ? Double(wValue) / 2.20462 : Double(wValue)
        let cals        = Int(round(0.0175 * 8.0 * weightKg * minutes))

        // 5) Store for summary
        justCompletedRecord   = newRecord
        justCompletedCalories = cals

        // 6) Show the summary
        showSummary = true
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    /// If sound is enabled, attempt to play the chosen file from “mySounds/”.
    private func playPhaseSound(for phase: Phase) {
        guard enableSound else { return }

        let rawName: String
        switch phase {
        case .work:
            rawName = workSoundRaw
        case .rest:
            rawName = restSoundRaw
        case .complete:
            rawName = completeSoundRaw
        default:
            return
        }

        SoundManager.shared.playSound(named: rawName)
    }
}

// MARK: – IntentionBanner (embedded to avoid “Cannot find IntentionBanner”)

struct IntentionBanner: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var onTap:     () -> Void
    var onDismiss: () -> Void

    @State private var autoDismissTask: Task<Void, Never>?

    private var bannerColor: Color {
        themeManager.selected == .gamer
            ? Color(red: 0.5, green: 0.3, blue: 0.06)
            : themeManager.selected.accent
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text("Tap to set today’s intention")
                .font(.headline)
                .foregroundColor(.white)
            Spacer(minLength: 0)
            Button(role: .cancel, action: onDismiss) {
                Image(systemName: "xmark")
                    .padding(6)
            }
            .tint(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(bannerColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(radius: 4, y: 2)
        .onTapGesture {
            onTap()
            autoDismissTask?.cancel()
        }
        .onAppear {
            autoDismissTask = Task {
                try? await Task.sleep(for: .seconds(7))
                await MainActor.run { onDismiss() }
            }
        }
        .accessibilityLabel("Set intention for workout")
    }
}

// MARK: – Preview

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(workoutName: "Demo Workout")
            .environmentObject(ThemeManager.shared)
            .previewLayout(.fixed(width: 375, height: 800))
    }
}

