// TimerView.swift
// IntervalTimer
// Core timer UI with auto‑dismissing IntentionBanner

import SwiftUI
import AVFoundation

struct TimerView: View {
    // MARK: – User‑configurable settings
    @AppStorage("timerDuration") private var timerDuration: Int = 60
    @AppStorage("restDuration")  private var restDuration:  Int = 30
    @AppStorage("sets")          private var sets:         Int = 1

    // MARK: – Timer state
    @State private var currentTime:      Int   = 60
    @State private var currentSet:       Int   = 1
    @State private var isRunning:        Bool  = false
    @State private var isResting:        Bool  = false
    @State private var activityComplete: Bool  = false
    @State private var timer:            Timer?

    // MARK: – Banner & Intentions sheet
    @State private var showBanner:     Bool = true
    @State private var showIntentions: Bool = false

    // MARK: – Audio
    @State private var audioPlayer: AVAudioPlayer?

    // Computed for ProgressView
    private var totalDuration: Int {
        isResting ? restDuration : timerDuration
    }
    private var elapsedTime: Int {
        max(0, totalDuration - currentTime)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // — AUTO‑DISMISSING BANNER —
                if showBanner {
                    IntentionBanner(
                        onTap:     { showIntentions = true },
                        onDismiss: { showBanner = false }
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Spacer()

                // Big timer
                Text(formatTime(seconds: currentTime))
                    .font(.system(
                        size: geometry.size.width > geometry.size.height ? 120 : 100,
                        weight: .bold,
                        design: .monospaced
                    ))
                    .foregroundColor(activityComplete ? .black : .primary)

                // Subtitle
                Text(activityComplete
                     ? "Great Work!"
                     : (isResting ? "Rest Time" : "Set \(currentSet) of \(sets)")
                )
                .font(activityComplete ? .title : .title2)
                .foregroundColor(activityComplete ? .black : .secondary)

                Spacer()

                // Progress bar
                ProgressView(value: Double(elapsedTime),
                             total: Double(totalDuration))
                    .progressViewStyle(
                        LinearProgressViewStyle(
                            tint: isResting ? .cyan : .green
                        )
                    )
                    .scaleEffect(x: 1, y: 4)
                    .padding(.horizontal)

                Spacer()

                // Play / Reset controls
                HStack(spacing: 40) {
                    Button(action: startTimer) {
                        ZStack {
                            Circle()
                                .fill(isRunning
                                      ? Color.red.opacity(0.2)
                                      : Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: isRunning
                                  ? "pause.circle.fill"
                                  : "play.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(isRunning ? .red : .blue)
                        }
                    }

                    Button(action: resetTimer) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(minHeight: geometry.size.height)
            .ignoresSafeArea(edges: .top)
            // — Intentions sheet —
            .sheet(isPresented: $showIntentions) {
                IntentionsView()
            }
        }
        // Sync on settings change
        .task { syncWithSettings() }
        .task(id: timerDuration) { syncWithSettings() }
        .task(id: restDuration)  { syncWithSettings() }
        .task(id: sets)          { syncWithSettings() }
    }

    // MARK: – Sync / Control logic

    private func syncWithSettings() {
        timer?.invalidate()
        isRunning        = false
        activityComplete = false
        isResting        = false
        currentSet       = 1
        currentTime      = timerDuration
    }

    private func startTimer() {
        if isRunning {
            timer?.invalidate()
        } else {
            if currentTime == 0 { advancePhase() }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if currentTime > 0 {
                    currentTime -= 1
                } else {
                    advancePhase()
                }
            }
        }
        isRunning.toggle()
    }

    private func advancePhase() {
        if isResting {
            if currentSet < sets {
                playSound(named: "work")
                currentSet += 1
                isResting = false
                currentTime = timerDuration
            } else {
                completeActivity()
            }
        } else {
            playSound(named: "rest")
            isResting   = true
            currentTime = restDuration
        }
    }

    private func resetTimer() {
        syncWithSettings()
    }

    private func completeActivity() {
        timer?.invalidate()
        isRunning        = false
        activityComplete = true
        playSound(named: "complete")
        saveSessionRecord()
    }

    // MARK: – Persistence

    private func saveSessionRecord() {
        var history: [SessionRecord] = []
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded
        }
        let record = SessionRecord(
            date:          Date(),
            timerDuration: timerDuration,
            restDuration:  restDuration,
            sets:          sets
        )
        history.append(record)
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "sessionHistory")
        }
    }

    // MARK: – Helpers

    private func formatTime(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func playSound(named name: String) {
        guard let asset = NSDataAsset(name: name) else {
            print("Sound asset \(name) not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: asset.data)
            audioPlayer?.play()
        } catch {
            print("Audio error: \(error.localizedDescription)")
        }
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
                Image(systemName: "xmark")
                    .padding(6)
            }
            .tint(.white)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
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

