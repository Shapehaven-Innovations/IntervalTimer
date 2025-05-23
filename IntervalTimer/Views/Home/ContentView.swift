//
//  ContentView.swift
//  IntervalTimer
//
//  Created by You on \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none))
//  Updated with bed wobble, bolt pulse & target pulse animations.
//

import SwiftUI
import UIKit

// MARK: – Fireball Model

struct Fireball: Identifiable {
    let id = UUID()
    let x: CGFloat      // horizontal start (0…1)
    let size: CGFloat   // point size
    let speed: Double   // seconds bottom→top
}

// MARK: – Fireball View

private struct FireballView: View {
    let fb: Fireball
    let geoSize: CGSize
    let onComplete: () -> Void

    @State private var animate = false

    var body: some View {
        Image(systemName: "flame.fill")
            .font(.system(size: fb.size))
            .foregroundColor(.orange)
            .shadow(color: .red, radius: fb.size * 0.3)
            .rotationEffect(.degrees(animate ? 360 : 0))
            .offset(
                x: (fb.x - 0.5) * geoSize.width,
                y: animate
                    ? -geoSize.height/2 - fb.size
                    : geoSize.height/2 + fb.size
            )
            .onAppear {
                withAnimation(.linear(duration: fb.speed)) {
                    animate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + fb.speed) {
                    onComplete()
                }
            }
    }
}

// MARK: – Animated Gradient Background

private struct AnimatedGradientBackground: View {
    @State private var animate = false

    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.purple.opacity(0.6),
                Color.blue.opacity(0.4),
                Color.black
            ]),
            center: .center,
            startRadius: animate ? 50 : 150,
            endRadius: animate ? 500 : 300
        )
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true),
                   value: animate)
        .onAppear { animate = true }
    }
}

// MARK: – Fireball Background

private struct FireballBackground: View {
    @State private var fireballs: [Fireball] = []
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AnimatedGradientBackground()
                ForEach(fireballs) { fb in
                    FireballView(fb: fb, geoSize: geo.size) {
                        fireballs.removeAll { $0.id == fb.id }
                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                fireballs.append(
                    Fireball(
                        x: .random(in: 0...1),
                        size: .random(in: 30...70),
                        speed: .random(in: 4...7)
                    )
                )
            }
        }
    }
}

// MARK: – Pressable Button Style

fileprivate struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.4 : 0),
                            lineWidth: 4)
                    .scaleEffect(configuration.isPressed ? 1.3 : 0.1)
                    .opacity(configuration.isPressed ? 0 : 1)
                    .animation(.easeOut(duration: 0.4),
                               value: configuration.isPressed)
            )
    }
}

// MARK: – Shimmer Modifier

fileprivate struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.2),
                        .white.opacity(0.6),
                        .white.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase * 350)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5)
                                .repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}
fileprivate extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}

// MARK: – AnimatedTile Modifier

private struct AnimatedTile: ViewModifier {
    let index: Int
    let animate: Bool

    func body(content: Content) -> some View {
        content
            .opacity(animate ? 1 : 0)
            .scaleEffect(animate ? 1 : 0.7)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.05),
                value: animate
            )
    }
}
private extension View {
    func animatedTile(index: Int, animate: Bool) -> some View {
        modifier(AnimatedTile(index: index, animate: animate))
    }
}

// MARK: – ConfigTileView

private struct ConfigTileView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let action: () -> Void

    @State private var wobble = false
    @State private var shrink = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .rotationEffect(
                        icon == "bed.double.fill"
                        ? Angle(degrees: wobble ? 10 : -10)
                        : .zero
                    )
                    .scaleEffect(
                        icon == "bolt.fill"
                        ? (shrink ? 0.8 : 1.0)
                        : 1.0
                    )
                    .onAppear {
                        if icon == "bed.double.fill" {
                            withAnimation(
                                .easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true)
                            ) { wobble.toggle() }
                        }
                        if icon == "bolt.fill" {
                            withAnimation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                            ) { shrink.toggle() }
                        }
                    }

                Text(label).font(.headline)
                Text(value).font(.subheadline).bold()
            }
            .foregroundColor(.white)
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: – Main ContentView

struct ContentView: View {
    @AppStorage("getReadyDuration")    private var _getReadyDuration = 3
    @AppStorage("timerDuration")       private var _timerDuration    = 20
    @AppStorage("restDuration")        private var _restDuration     = 10
    @AppStorage("sets")                private var _sets             = 8
    @AppStorage("lastWorkoutName")     private var lastWorkoutName  = ""
    @AppStorage("savedConfigurations") private var configsData: Data = Data()

    @State private var configs: [SessionRecord] = []
    @State private var activePicker: PickerType?
    @State private var showingTimer        = false
    @State private var showingConfigEditor = false
    @State private var showingWorkoutLog   = false
    @State private var showingIntention    = false
    @State private var showingAnalytics    = false
    @State private var animateTiles        = false

    private var name: String { UIDevice.current.name }

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
                return Binding(get: { _getReadyDuration },
                               set: { _getReadyDuration = $0; lastWorkoutName = "" })
            case .rounds:
                return Binding(get: { _sets },
                               set: { _sets = $0; lastWorkoutName = "" })
            case .work:
                return Binding(get: { _timerDuration },
                               set: { _timerDuration = $0; lastWorkoutName = "" })
            case .rest:
                return Binding(get: { _restDuration },
                               set: { _restDuration = $0; lastWorkoutName = "" })
        }
    }

    // New state for pulsing target
    @State private var pulseTarget = false

    var body: some View {
        NavigationView {
            ZStack {
                FireballBackground()

                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()), GridItem(.flexible())
                    ], spacing: 20) {
                        // Bolt (shrinks/grows)
                        ConfigTileView(
                            icon:  "bolt.fill",
                            label: "Get Ready",
                            value: format(_getReadyDuration),
                            color: Theme.cardBackgrounds[0]
                        ) {
                            activePicker = .getReady
                        }
                        .animatedTile(index: 0, animate: animateTiles)

                        // Rounds
                        ConfigTileView(
                            icon:  "repeat.circle.fill",
                            label: "Rounds", value: "\(_sets)",
                            color: Theme.cardBackgrounds[1]
                        ) { activePicker = .rounds }
                        .animatedTile(index: 1, animate: animateTiles)

                        // Work
                        ConfigTileView(
                            icon:  "flame.fill",
                            label: "Work", value: format(_timerDuration),
                            color: Theme.cardBackgrounds[2]
                        ) { activePicker = .work }
                        .animatedTile(index: 2, animate: animateTiles)

                        // Rest (wobbles)
                        ConfigTileView(
                            icon:  "bed.double.fill",
                            label: "Rest", value: format(_restDuration),
                            color: Theme.cardBackgrounds[3]
                        ) { activePicker = .rest }
                        .animatedTile(index: 3, animate: animateTiles)

                        // Start Workout
                        Button { showingTimer = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                Text("Start Workout").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(Theme.cardBackgrounds[4])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shimmer()
                            .shadow(color: Theme.cardBackgrounds[4].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 4, animate: animateTiles)

                        // Save Workout
                        Button { showingConfigEditor = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                Text("Save Workout").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(Theme.cardBackgrounds[5])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Theme.cardBackgrounds[5].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 5, animate: animateTiles)

                        // Workout Log
                        Button { showingWorkoutLog = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "list.bullet.clipboard.fill")
                                    .font(.largeTitle)
                                Text("Workout Log").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(Theme.cardBackgrounds[6])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Theme.cardBackgrounds[6].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 6, animate: animateTiles)

                        // Intention (pulses)
                        Button { showingIntention = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "target")
                                    .font(.largeTitle)
                                    .scaleEffect(pulseTarget ? 1.2 : 0.8)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.9)
                                                        .repeatForever(autoreverses: true)) {
                                            pulseTarget.toggle()
                                        }
                                    }
                                Text("Intention").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(Theme.cardBackgrounds[7])
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Theme.cardBackgrounds[7].opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 7, animate: animateTiles)

                        // Analytics
                        Button { showingAnalytics = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar.doc.horizontal.fill")
                                    .font(.largeTitle)
                                Text("Analytics").font(.headline)
                            }
                            .frame(minHeight: 140).frame(maxWidth: .infinity)
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Theme.accent.opacity(0.3),
                                    radius: 6, x: 0, y: 5)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .animatedTile(index: 8, animate: animateTiles)

                        // Saved Configs
                        ForEach(Array(configs.enumerated()), id: \.element.id) { idx, record in
                            Button {
                                _timerDuration  = record.timerDuration
                                _restDuration   = record.restDuration
                                _sets           = record.sets
                                lastWorkoutName = record.name
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.largeTitle)
                                    Text(record.name).font(.headline)
                                    Text("\(format(record.timerDuration)) / \(format(record.restDuration)) / \(record.sets)x")
                                        .font(.subheadline).bold()
                                }
                                .frame(minHeight: 140).frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.gray.opacity(0.3),
                                        radius: 6, x: 0, y: 5)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    configs.removeAll { $0.id == record.id }
                                    if let data = try? JSONEncoder().encode(configs) {
                                        configsData = data
                                    }
                                } label: {
                                    Label("Delete “\(record.name)”", systemImage: "trash")
                                }
                            }
                            .animatedTile(index: 9 + idx, animate: animateTiles)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Hello, \(UIDevice.current.name)!")
                .navigationBarTitleDisplayMode(.large)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)

                // Sheets & load logic
                .sheet(item: $activePicker) { p in
                    PickerSheet(type: p, value: binding(for: p))
                }
                .sheet(isPresented: $showingTimer)        { TimerView(workoutName: lastWorkoutName) }
                .sheet(isPresented: $showingConfigEditor) {
                    ConfigurationEditorView(
                        timerDuration: _getReadyDuration,
                        restDuration:  _restDuration,
                        sets:          _sets
                    ) { newRec in
                        configs.insert(newRec, at: 0)
                        if let data = try? JSONEncoder().encode(configs) {
                            configsData = data
                        }
                        lastWorkoutName = newRec.name
                    }
                }
                .sheet(isPresented: $showingWorkoutLog)   { WorkoutLogView() }
                .sheet(isPresented: $showingIntention)    { IntentionsView() }
                .sheet(isPresented: $showingAnalytics)    { AnalyticsView() }
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
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: – PickerSheet

struct PickerSheet: View {
    let type: ContentView.PickerType
    @Binding var value: Int
    @Environment(\.presentationMode) private var presentationMode

    private var themeColor: Color {
        switch type {
            case .getReady: return Theme.cardBackgrounds[0]
            case .rounds:   return Theme.cardBackgrounds[1]
            case .work:     return Theme.cardBackgrounds[2]
            case .rest:     return Theme.cardBackgrounds[3]
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                themeColor.opacity(0.1).ignoresSafeArea()
                Form {
                    Section(header: Text(type.title)) {
                        Stepper("\(value) seconds", value: $value, in: 1...300)
                    }
                }
            }
            .navigationTitle(type.title)
            .toolbar {
                Button("Done") { presentationMode.wrappedValue.dismiss() }
            }
        }
    }
}

