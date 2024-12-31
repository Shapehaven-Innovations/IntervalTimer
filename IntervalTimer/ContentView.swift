//
//  ContentView.swift
//  IntervalTimer
//
//  Created by user on 12/17/24.

import SwiftUI
import Combine
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
    @State private var audioPlayer: AVAudioPlayer?

    // Enum for navigation
    enum Destination: Hashable {
        case settings
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height

                ZStack {
                    // Background color
                    Color.white
                        .edgesIgnoringSafeArea(.all)

                    if isLandscape {
                        HStack(spacing: 20) {
                            timerView
                                .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.9)
                            controlPanel
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.9)
                        }
                    } else {
                        VStack(spacing: 5) {
                            timerView
                                .frame(height: geometry.size.height * 0.7)
                            controlPanel
                                .frame(height: geometry.size.height * 0.3)
                        }
                    }
                }
                .padding()
            }
            // Define navigationDestination for the "Destination.settings" value
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .settings:
                    SettingsView(timerDuration: $timerDuration, restDuration: $restDuration, sets: $sets)
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar
        }
    }

    // Timer View
    private var timerView: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20) // Thick stroke
                    .frame(width: 250, height: 250)

                Circle()
                    .trim(from: 0, to: progress())
                    .stroke(isResting ? Color.cyan : Color.green, lineWidth: 20)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress())
                    .frame(width: 250, height: 250)

                Text(formatTime(seconds: currentTime))
                    .font(.system(size: 50, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
            Text(activityComplete ? "Great Work!" : isResting ? "Rest Time" : "Set \(currentSet) of \(sets)")
                .font(.title3)
                .foregroundColor(.secondary)
                .padding(.top, 20)
        }
    }

    // Control Panel
    private var controlPanel: some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                Button(action: { startTimer() }) {
                    Text(isRunning ? "Pause" : "Start")
                        .font(.title2)
                        .frame(width: 130, height: 50)
                        .background(isRunning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: { resetTimer() }) {
                    Text("Reset")
                        .font(.title2)
                        .frame(width: 130, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }

            NavigationLink(value: Destination.settings) {
                Text("Interval Configuration")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.top, 5)
    }

    // Timer logic
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
                        playSound(soundName: "complete")
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
                            playSound(soundName: "complete")
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
    }

    private func progress() -> CGFloat {
        let totalTime = isResting ? restDuration : timerDuration
        return CGFloat(currentTime) / CGFloat(totalTime)
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

