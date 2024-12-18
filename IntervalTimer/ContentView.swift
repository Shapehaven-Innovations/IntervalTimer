//
//  ContentView.swift
//  IntervalTimer
//
//  Created by user on 12/17/24.
//
import SwiftUI
import Combine

@main
struct IntervalTimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var timerDuration: Int = 60
    @State private var restDuration: Int = 30
    @State private var currentTime: Int = 60
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var sets: Int = 1
    @State private var currentSet: Int = 1
    @State private var isResting: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Interval Timer")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 50)
                    .padding()
                    .foregroundColor(.mint)

                Text(isResting ? "Rest" : "Set \(currentSet) of \(sets)")
                    .font(.title2)
                    .foregroundColor(Color.primary)

                Text(formatTime(seconds: currentTime))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.primary)

                HStack(spacing: 20) {
                    Button(action: startTimer) {
                        Text(isRunning ? "Pause" : "Start")
                            .font(.title)
                            .padding()
                            .background(Color.mint)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: resetTimer) {
                        Text("Reset")
                            .font(.title)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                Spacer()

                NavigationLink(destination: SettingsView(timerDuration: $timerDuration, restDuration: $restDuration, sets: $sets)) {
                    Text("Interval Configuration")
                        .font(.title2)
                        .padding()
                        .background(Color.mint.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.horizontal))
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func startTimer() {
        if isRunning {
            timer?.invalidate()
        } else {
            if currentTime == 0 {
                if isResting {
                    if currentSet < sets {
                        currentSet += 1
                        isResting = false
                        currentTime = timerDuration
                    } else {
                        timer?.invalidate()
                        return
                    }
                } else {
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
                            currentSet += 1
                            isResting = false
                            currentTime = timerDuration
                        } else {
                            timer?.invalidate()
                        }
                    } else {
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
    }

    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SettingsView: View {
    @Binding var timerDuration: Int
    @Binding var restDuration: Int
    @Binding var sets: Int

    var body: some View {
        VStack {
            Text("Interval Configuration Settings")
                .font(.largeTitle)
                .padding()

            Stepper(value: $timerDuration, in: 10...3600, step: 5) {
                Text("Work Duration: \(timerDuration) seconds")
                    .font(.title2)
            }
            .padding()

            Stepper(value: $restDuration, in: 10...600, step: 10) {
                Text("Rest Duration: \(restDuration) seconds")
                    .font(.title2)
            }
            .padding()

            Stepper(value: $sets, in: 1...20, step: 1) {
                Text("Sets: \(sets)")
                    .font(.title2)
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}
