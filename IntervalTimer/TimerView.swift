// TimerView.swift
// IntervalTimer
// Core timer UI with Get‑Ready countdown + auto‑dismissing IntentionBanner

import SwiftUI
import AVFoundation

struct TimerView: View {
    // MARK: – User‑configurable settings
    @AppStorage("getReadyDuration") private var getReadyDuration: Int = 3
    @AppStorage("timerDuration")    private var timerDuration:    Int = 60
    @AppStorage("restDuration")     private var restDuration:     Int = 30
    @AppStorage("sets")             private var sets:             Int = 1

    // MARK: – Timer phases
    private enum Phase { case getReady, work, rest, complete }
    @State private var phase: Phase = .getReady
    @State private var currentTime: Int = 0
    @State private var currentSet:  Int = 1
    @State private var timer:        Timer?

    // MARK: – Banner & Intentions sheet
    @State private var showBanner:     Bool = true
    @State private var showIntentions: Bool = false

    // MARK: – Audio
    @State private var audioPlayer: AVAudioPlayer?

    // Computed for ProgressView
    private var totalDuration: Int {
        switch phase {
        case .getReady: return getReadyDuration
        case .work:     return timerDuration
        case .rest:     return restDuration
        case .complete: return 1
        }
    }
    private var elapsedTime: Int {
        totalDuration - currentTime
    }

    // MARK: – Dynamic background
    private var backgroundColor: Color {
        switch phase {
        case .getReady: return Theme.cardBackgrounds[0]   // yellow
        case .work:     return Theme.cardBackgrounds[3]   // redish
        case .rest:     return Theme.cardBackgrounds[5]   // blueish
        case .complete: return Theme.cardBackgrounds[2]   // greenish
        }
    }

    // MARK: – Controls style
    private let controlBackground = Color.white.opacity(0.3)
    private let controlForeground = Color.white

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // — Banner (optional) —
                    if showBanner {
                        IntentionBanner(
                            onTap:     { showIntentions = true },
                            onDismiss: { showBanner = false }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    // — Top Spacer —
                    Spacer()

                    // — Time & Subtitle —
                    Text(formatTime(seconds: currentTime))
                        .font(.system(
                            size: geo.size.width > geo.size.height ? 120 : 100,
                            weight: .bold,
                            design: .monospaced
                        ))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))

                    // — Spacer between text and progress —
                    Spacer()

                    // — Progress bar (always there, hidden during Get Ready) —
                    ProgressView(
                        value: phase == .getReady ? 0 : Double(elapsedTime),
                        total: Double(totalDuration)
                    )
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .scaleEffect(x: 1, y: 4)
                    .padding(.horizontal)
                    .opacity(phase == .getReady ? 0 : 1)

                    // — Spacer between progress and controls —
                    Spacer()

                    // — Controls —
                    HStack(spacing: 40) {
                        Button(action: toggleTimer) {
                            ZStack {
                                Circle()
                                    .fill(controlBackground)
                                    .frame(width: 80, height: 80)
                                Image(systemName: isRunning
                                      ? "pause.circle.fill"
                                      : "play.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(controlForeground)
                            }
                        }

                        Button(action: resetAll) {
                            ZStack {
                                Circle()
                                    .fill(controlBackground)
                                    .frame(width: 80, height: 80)
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(controlForeground)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(minHeight: geo.size.height)
            }
            .onAppear {
                // Prepare for manual start
                phase = .getReady
                currentTime = getReadyDuration
            }
            .onDisappear {
                // Clean up timer
                timer?.invalidate()
                timer = nil
            }
            .sheet(isPresented: $showIntentions) {
                IntentionsView()
            }
        }
    }

    // MARK: – Helpers & logic

    private var isRunning: Bool {
        timer != nil
    }

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
            // Start or resume current phase
            startTimerLoop()
        }
    }

    private func startTimerLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard currentTime > 0 else {
                advancePhase()
                return
            }
            currentTime -= 1
        }
    }

    private func advancePhase() {
        timer?.invalidate()
        timer = nil

        switch phase {
        case .getReady:
            phase = .work
            currentTime = timerDuration
            playSound(named: "work")
            startTimerLoop()

        case .work:
            if currentSet < sets {
                phase = .rest
                currentTime = restDuration
                playSound(named: "rest")
                startTimerLoop()
            } else {
                phase = .complete
                currentTime = 1
                playSound(named: "complete")
                completeAndSave()
            }

        case .rest:
            currentSet += 1
            phase = .work
            currentTime = timerDuration
            playSound(named: "work")
            startTimerLoop()

        case .complete:
            // Completed; wait for reset
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

    private func completeAndSave() {
        // Persist session record
        var history: [SessionRecord] = []
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded
        }
        history.append(.init(
            name:           "",
            date:           Date(),
            timerDuration:  timerDuration,
            restDuration:   restDuration,
            sets:           sets
        ))
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "sessionHistory")
        }
    }

    private func formatTime(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func playSound(named name: String) {
        guard let asset = NSDataAsset(name: name) else { return }
        audioPlayer = try? AVAudioPlayer(data: asset.data)
        audioPlayer?.play()
    }
}

// MARK: – IntentionBanner

struct IntentionBanner: View {
    var onTap:     () -> Void
    var onDismiss: () -> Void

    @State private var autoDismissTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text("Tap to set today’s intention")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer(minLength: 0)
            Button(role: .cancel, action: onDismiss) {
                Image(systemName: "xmark").padding(6)
            }
            .tint(.white)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(Color.accentColor)
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

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

