//
//  ContentView.swift
//  IntervalTimer
//
//  Created by user on 12/17/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var timerDuration: Int = 60
    @State private var restDuration: Int = 30
    @State private var currentTime: Int = 60
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var sets: Int = 1
    @State private var currentSet: Int = 1
    @State private var isResting: Bool = false
    @State private var activityComplete: Bool = false
    @State private var showConfetti: Bool = false
    @State private var audioPlayer: AVAudioPlayer?

    enum Destination: Hashable {
        case settings
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    ZStack {
                        VStack(spacing: 20) {
                            // Gear Icon for Configuration
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

                            // Timer Display
                            Text(formatTime(seconds: currentTime))
                                .font(
                                    .system(
                                        size: geometry.size.width > geometry.size.height ? 120 : 100,
                                        weight: .bold,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(activityComplete ? .black : .primary)

                            if !activityComplete {
                                Text(isResting ? "Rest Time" : "Set \(currentSet) of \(sets)")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Great Work!")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            // Progress Bar
                            ProgressView(value: progress())
                                .progressViewStyle(LinearProgressViewStyle(tint: isResting ? .cyan : .green))
                                .scaleEffect(x: 1, y: 4)
                                .padding(.horizontal)

                            Spacer()

                            // Control Buttons
                            HStack(spacing: 40) {
                                // Play/Pause Button
                                Button(action: { startTimer() }) {
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

                                // Reset Button
                                Button(action: { resetTimer() }) {
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
                            .padding(.bottom, 20)  // Extra bottom padding so it’s not clipped
                        }

                        // Confetti overlay
                        if showConfetti {
                            ConfettiView(isActive: showConfetti, width: geometry.size.width)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .settings:
                    SettingsView(timerDuration: $timerDuration,
                                 restDuration: $restDuration,
                                 sets: $sets)
                }
            }
            .padding()
        }
    }

    // MARK: - Timer Logic

    private func startTimer() {
        if isRunning {
            timer?.invalidate()
        } else {
            if currentTime == 0 {
                if isResting {
                    if currentSet < sets {
                        playSound(soundName: "work")
                        currentSet += 1
                        isResting = false
                        currentTime = timerDuration
                    } else {
                        completeActivity()
                        return
                    }
                } else {
                    playSound(soundName: "rest")
                    isResting = true
                    currentTime = restDuration
                }
            }

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if currentTime > 0 {
                    currentTime -= 1
                } else {
                    if isResting {
                        if currentSet < sets {
                            playSound(soundName: "work")
                            currentSet += 1
                            isResting = false
                            currentTime = timerDuration
                        } else {
                            completeActivity()
                            return
                        }
                    } else {
                        playSound(soundName: "rest")
                        isResting = true
                        currentTime = restDuration
                    }
                }
            }
        }
        isRunning.toggle()
    }

    private func resetTimer() {
        timer?.invalidate()
        currentTime = timerDuration
        currentSet = 1
        isResting = false
        isRunning = false
        activityComplete = false
    }

    private func completeActivity() {
        timer?.invalidate()
        isRunning = false
        activityComplete = true
        playSound(soundName: "complete")
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            showConfetti = false
        }
    }

    // MARK: - Utility

    // Updated progress function that clamps value between 0 and 1
    private func progress() -> Double {
        let totalTime = isResting ? restDuration : timerDuration
        guard totalTime > 0 else { return 0.0 }

        // fraction = portion of the current interval completed
        let fraction = Double(totalTime - currentTime) / Double(totalTime)

        // Make sure progress stays within [0, 1] to avoid warnings
        return min(max(fraction, 0.0), 1.0)
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("Sound asset \(soundName) not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer?.play()
        } catch {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
}

