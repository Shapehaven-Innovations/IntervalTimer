////
//  ContentView.swift
//  IntervalTimer
//
//  Created by You on \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none))
//  Updated with enhanced animations, white nav title, and all dependencies.
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
                    :  geoSize.height/2 + fb.size
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
            endRadius:   animate ? 500 : 300
        )
        .animation(
            .easeInOut(duration: 8)
                .repeatForever(autoreverses: true),
            value: animate
        )
        .onAppear { animate = true }
    }
}

// MARK: – Fireball Background

private struct FireballBackground: View {
    @State private var fireballs: [Fireball] = []
    private let launchTimer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

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
            .onReceive(launchTimer) { _ in
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
                withAnimation(
                    .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) { phase = 1 }
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
            .scaleEffect(animate ? 1 : 0.7, anchor: .center)
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

// MARK: – Haptic Helper

private func withHaptic(_ action: @escaping () -> Void) -> () -> Void {
    return {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        action()
    }
}

// MARK: – ContentView

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
                               set: { _getReadyDuration = $0
                                      lastWorkoutName = "" })
            case .rounds:
                return Binding(get: { _sets },
                               set: { _sets = $0
                                      lastWorkoutName = "" })
            case .work:
                return Binding(get: { _timerDuration },
                               set: { _timerDuration = $0
                                      lastWorkoutName = "" })
            case .rest:
                return Binding(get: { _restDuration },
                               set: { _restDuration = $0
                                      lastWorkoutName = "" })
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                FireballBackground()

                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 20
                    ) {
                        // — Config Tiles —
                        configTile(icon:  "bolt.fill",
                                   label: "Get Ready",
                                   value: format(_getReadyDuration),
                                   type:  .getReady,
                                   color: Theme.cardBackgrounds[0])
                            .animatedTile(index: 0, animate: animateTiles)

                        configTile(icon:  "repeat.circle.fill",
                                   label: "Rounds",
                                   value: "\(_sets)",
                                   type:  .rounds,
                                   color: Theme.cardBackgrounds[1])
                            .animatedTile(index: 1, animate: animateTiles)

                        configTile(icon:  "flame.fill",
                                   label: "Work",
                                   value: format(_timerDuration),
                                   type:  .work,
                                   color: Theme.cardBackgrounds[2])
                            .animatedTile(index: 2, animate: animateTiles)

                        configTile(icon:  "bed.double.fill",
                                   label: "Rest",
                                   value: format(_restDuration),
                                   type:  .rest,
                                   color: Theme.cardBackgrounds[3])
                            .animatedTile(index: 3, animate: animateTiles)

                        // — Action Tiles —
                        actionTile(icon:  "play.circle.fill",
                                   label: "Start Workout",
                                   color: Theme.cardBackgrounds[4],
                                   action: withHaptic { showingTimer = true })
                            .shimmer()
                            .animatedTile(index: 4, animate: animateTiles)

                        actionTile(icon:  "plus.circle.fill",
                                   label: "Save Workout",
                                   color: Theme.cardBackgrounds[5],
                                   action: withHaptic { showingConfigEditor = true })
                            .animatedTile(index: 5, animate: animateTiles)

                        actionTile(icon:  "list.bullet.clipboard.fill",
                                   label: "Workout Log",
                                   color: Theme.cardBackgrounds[6],
                                   action: withHaptic { showingWorkoutLog = true })
                            .animatedTile(index: 6, animate: animateTiles)

                        actionTile(icon:  "target",
                                   label: "Intention",
                                   color: Theme.cardBackgrounds[7],
                                   action: withHaptic { showingIntention = true })
                            .animatedTile(index: 7, animate: animateTiles)

                        actionTile(icon:  "chart.bar.doc.horizontal.fill",
                                   label: "Analytics",
                                   color: Theme.accent,
                                   action: withHaptic { showingAnalytics = true })
                            .animatedTile(index: 8, animate: animateTiles)

                        // — Saved Configurations —
                        ForEach(Array(configs.enumerated()), id: \.element.id) { idx, record in
                            Button {
                                UIImpactFeedbackGenerator(style: .light)
                                    .impactOccurred()
                                _timerDuration  = record.timerDuration
                                _restDuration   = record.restDuration
                                _sets           = record.sets
                                lastWorkoutName = record.name
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.largeTitle)
                                    Text(record.name)
                                        .font(.headline)
                                    Text("\(format(record.timerDuration)) / \(format(record.restDuration)) / \(record.sets)x")
                                        .font(.subheadline)
                                        .bold()
                                }
                                .foregroundColor(.white)
                                .frame(minHeight: 140)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(16)
                                .shadow(color: Color.gray.opacity(0.3),
                                        radius: 6, x: 0, y: 5)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    configs.removeAll { $0.id == record.id }
                                    saveConfigs()
                                } label: {
                                    Label("Delete \"\(record.name)\"", systemImage: "trash")
                                }
                            }
                            .animatedTile(index: 9 + idx, animate: animateTiles)
                        }
                    }
                    .padding()
                }
            }
            // — make nav title & buttons white —
            .navigationTitle("Hello, \(name)!")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)

            // — sheets & onAppear —
            .sheet(item: $activePicker) { picker in
                PickerSheet(type: picker, value: binding(for: picker))
            }
            .sheet(isPresented: $showingTimer)        { TimerView(workoutName: lastWorkoutName) }
            .sheet(isPresented: $showingConfigEditor) {
                ConfigurationEditorView(
                    timerDuration: _timerDuration,
                    restDuration:  _restDuration,
                    sets:          _sets
                ) { newRecord in
                    configs.insert(newRecord, at: 0)
                    saveConfigs()
                    lastWorkoutName = newRecord.name
                }
            }
            .sheet(isPresented: $showingWorkoutLog)   { WorkoutLogView() }
            .sheet(isPresented: $showingIntention)    { IntentionsView() }
            .sheet(isPresented: $showingAnalytics)    { AnalyticsView() }
            .onAppear {
                if let decoded = try? JSONDecoder()
                    .decode([SessionRecord].self, from: configsData) {
                    configs = decoded
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateTiles = true
                }
            }
        }
    }

    // MARK: – Tile Builders

    private func configTile(icon: String,
                            label: String,
                            value: String,
                            type:  PickerType,
                            color: Color) -> some View
    {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            activePicker = type
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .rotationEffect(.degrees(activePicker == type ? 15 : -15))
                    .animation(
                        .easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                        value: activePicker
                    )
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

    private func actionTile(icon: String,
                            label: String,
                            color: Color,
                            action: @escaping () -> Void) -> some View
    {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .scaleEffect(1.1)
                    .animation(
                        .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                        value: animateTiles
                    )
                Text(label).font(.headline)
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

    // MARK: – Helpers

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func saveConfigs() {
        if let encoded = try? JSONEncoder().encode(configs) {
            configsData = encoded
        }
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

