//
//  ContentView.swift
//  IntervalTimer
//
//  Created by user on 12/17/24.
//
import SwiftUI
import Combine
import AVFoundation

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
    @State private var activityComplete: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Interval Timer")
                    .font(.system(size: 50, weight: .bold)) // Increased font size for title
                    .padding(.top, 50)
                    .padding()
                    .foregroundColor(Color.black)
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress())
                        .stroke(isResting ? Color.cyan : Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress())
                    
                    if activityComplete {
                        Text("Mission Complete")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color.green)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(formatTime(seconds: currentTime))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.primary)
                    }
                }
                
                Text(activityComplete ? "Great Work!" : (isResting ? "Rest" : "Set \(currentSet) of \(sets)"))
                    .font(.title2)
                    .foregroundColor(Color.primary)
                
                HStack(spacing: 20) {
                    Button(action: { startTimer() }) {
                        Text(isRunning ? "Pause" : "Start")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { resetTimer() }) {
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
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                }
            }
            .padding()
            .onRotate(perform: handleOrientationChange)
        }
    }
    
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
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func progress() -> CGFloat {
        let totalTime = isResting ? restDuration : timerDuration
        return CGFloat(currentTime) / CGFloat(totalTime)
    }
    
    private func handleOrientationChange(orientation: UIDeviceOrientation) {
        if orientation.isLandscape {
            print("Switched to landscape mode")
        } else if orientation.isPortrait {
            print("Switched to portrait mode")
        }
    }
    
    private func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("Sound asset \(soundName) not found in Asset Catalog.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer?.play()
        } catch {
            print("Error creating audioPlayer: \(error.localizedDescription)")
        }
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

            Stepper(value: $restDuration, in: 10...600, step: 5) {
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

    extension View {
        func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
            self.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
        }
    }
