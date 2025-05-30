//
//  TimerView.swift
//  IntervalTimer
//  Core timer UI with Get‑Ready + mixing with background audio + in‑view IntentionBanner
//

import SwiftUI
import AVFoundation

struct TimerView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    /// Passed in from ContentView
    let workoutName: String

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

    // MARK: – Banner & Intentions
    @State private var showBanner:     Bool = true
    @State private var showIntentions: Bool = false

    // MARK: – Audio
    @State private var audioPlayer: AVAudioPlayer?

    // Computed
    private var totalDuration: Int {
        switch phase {
        case .getReady: return getReadyDuration
        case .work:     return timerDuration
        case .rest:     return restDuration
        case .complete: return 1
        }
    }
    private var elapsedTime: Int { totalDuration - currentTime }

    // Dynamic background via ThemeManager
    private var backgroundColor: Color {
        let palette = themeManager.selected.cardBackgrounds
        switch phase {
        case .getReady: return palette[0]
        case .work:     return palette[2]
        case .rest:     return palette[3]
        case .complete: return palette[5]
        }
    }

    // Controls style
    private let controlBackground = Color.white.opacity(0.3)
    private let controlForeground = Color.white

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

                    Spacer()

                    ProgressView(
                        value: phase == .getReady ? 0 : Double(elapsedTime),
                        total: Double(totalDuration)
                    )
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .scaleEffect(x: 1, y: 4)
                    .padding(.horizontal)
                    .opacity(phase == .getReady ? 0 : 1)

                    Spacer()

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
                configureAudioSession()
                phase = .getReady
                currentTime = getReadyDuration
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .sheet(isPresented: $showIntentions) {
                IntentionsView()
                    .environmentObject(themeManager)
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
        let newTimer = Timer(timeInterval: 1, repeats: true) { _ in
            guard currentTime > 0 else {
                advancePhase()
                return
            }
            currentTime -= 1
        }
        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
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
                currentTime = 0
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
        var history: [SessionRecord] = []
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded
        }
        let record = SessionRecord(
            name:           workoutName,
            date:           Date(),
            timerDuration:  timerDuration,
            restDuration:   restDuration,
            sets:           sets
        )
        history.append(record)
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

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session config failed: \(error)")
        }
    }
}

// MARK: – IntentionBanner

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

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(workoutName: "Demo")
            .environmentObject(ThemeManager.shared)
    }
}

