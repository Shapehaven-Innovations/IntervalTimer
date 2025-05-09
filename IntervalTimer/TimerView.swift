// TimerView.swift
// IntervalTimer
// Core timer UI with dynamic settings sync

import SwiftUI
import AVFoundation

enum Destination: Hashable {
    case settings
}

struct TimerView: View {
    // Live bindings to Settings values
    @AppStorage("timerDuration") private var timerDuration: Int = 60
    @AppStorage("restDuration") private var restDuration: Int = 30
    @AppStorage("sets") private var sets: Int = 1

    // Timer state
    @State private var currentTime: Int = 60
    @State private var currentSet: Int = 1
    @State private var isRunning: Bool = false
    @State private var isResting: Bool = false
    @State private var activityComplete: Bool = false
    @State private var timer: Timer? = nil
    @State private var audioPlayer: AVAudioPlayer?

    // MARK: – Computed for ProgressView
    private var totalDuration: Int {
        isResting ? restDuration : timerDuration
    }
    private var elapsedTime: Int {
        max(0, min(totalDuration, totalDuration - currentTime))
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    // Settings button
                    HStack {
                        Spacer()
                        NavigationLink(value: Destination.settings) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }

                    Spacer()

                    // Time display
                    Text(formatTime(seconds: currentTime))
                        .font(.system(
                            size: geometry.size.width > geometry.size.height ? 120 : 100,
                            weight: .bold,
                            design: .monospaced
                        ))
                        .foregroundColor(activityComplete ? .black : .primary)

                    // Subtitle
                    if activityComplete {
                        Text("Great Work!")
                            .font(.title)
                            .foregroundColor(.black)
                    } else {
                        Text(isResting ? "Rest Time" : "Set \(currentSet) of \(sets)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Progress bar
                    ProgressView(value: Double(elapsedTime), total: Double(totalDuration))
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: isResting ? .cyan : .green)
                        )
                        .scaleEffect(x: 1, y: 4)
                        .padding(.horizontal)

                    Spacer()

                    // Controls
                    HStack(spacing: 40) {
                        Button(action: startTimer) {
                            ZStack {
                                Circle()
                                    .fill(isRunning ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
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
            }
            .navigationDestination(for: Destination.self) { _ in
                ContentView()
            }
            .task { syncWithSettings() }
            .task(id: timerDuration) { syncWithSettings() }
            .task(id: restDuration) { syncWithSettings() }
            .task(id: sets) { syncWithSettings() }
        }
    }

    // MARK: – Sync settings
    private func syncWithSettings() {
        timer?.invalidate()
        isRunning        = false
        activityComplete = false
        isResting        = false
        currentSet       = 1
        currentTime      = timerDuration
    }

    // MARK: – Timer Logic
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
            isResting = true
            currentTime = restDuration
        }
    }

    // MARK: – Reset
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

    // MARK: – Session Tracking
    private func saveSessionRecord() {
        var history: [SessionRecord] = []
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded
        }
        let record = SessionRecord(
            date: Date(),
            timerDuration: timerDuration,
            restDuration: restDuration,
            sets: sets
        )
        history.append(record)
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "sessionHistory")
        }
    }

    // MARK: – Utility
    private func formatTime(seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
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

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

