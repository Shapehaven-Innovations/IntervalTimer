// PickerSheet.swift
//
//  PickerSheet.swift
//  IntervalTimer
//  Modernized duration picker in minutes & seconds
//  Updated 05/31/25 so that it responds to Dark/Light Mode
//

import SwiftUI

/// A modal sheet that lets the user pick durations or rounds with an interactive, animated UI.
struct PickerSheet: View {
    let type: PickerType
    @Binding var value: Int

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private let maxSeconds = 300
    private let maxRounds = 20
    private var maxMinutes: Int { maxSeconds / 60 }

    // Internal state for sliders/dials
    @State private var minutes: Double
    @State private var seconds: Double
    @State private var rounds: Double

    // MARK: – Gradient and solid colors for the “accent” on this sheet
    private var themeGradient: LinearGradient {
        let colors = [themeColor, themeColor.opacity(0.7)]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var themeColor: Color {
        switch type {
        case .getReady: return themeManager.selected.cardBackgrounds[0]
        case .rounds:   return themeManager.selected.cardBackgrounds[1]
        case .work:     return themeManager.selected.cardBackgrounds[2]
        case .rest:     return themeManager.selected.cardBackgrounds[3]
        }
    }

    init(type: PickerType, value: Binding<Int>) {
        self.type = type
        self._value = value

        // Initialize state from the binding’s current value (clamped)
        let initial = min(max(value.wrappedValue, 1), maxSeconds)
        _minutes = State(initialValue: Double(initial / 60))
        _seconds = State(initialValue: Double(initial % 60))
        _rounds  = State(initialValue: Double(min(max(value.wrappedValue, 1), maxRounds)))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 1) Full‑screen, dynamic background
                Color(.systemBackground)
                    .ignoresSafeArea()
                // 2) Slight tinted overlay to pick up a bit of themeColor
                themeColor.opacity(0.05)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    headerView

                    cardView
                        .animation(
                            .interactiveSpring(response: 0.4, dampingFraction: 0.8, blendDuration: 0),
                            value: animationTrigger
                        )

                    previewView

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    // empty placeholder to center title
                    Color.clear.frame(height: 0)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        syncValue()
                        dismiss()
                    }
                }
            }
        }
        // ← No forced colorScheme here. PickerSheet now inherits the app’s colorScheme.
    }

    // MARK: – Header with dynamic gradient text and icon
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: type.iconName)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(themeGradient)
                .scaleEffect(1.2)

            Text(type.title.uppercased())
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(themeGradient)
        }
    }

    // MARK: – Main interactive card (either “Rounds” slider or “Minutes/Seconds” sliders)
    @ViewBuilder
    private var cardView: some View {
        if type == .rounds {
            VStack(spacing: 20) {
                Text("Rounds: \(Int(rounds))")
                    .font(.title2.weight(.medium))
                    .foregroundColor(themeColor)

                Slider(
                    value: Binding(
                        get: { rounds },
                        set: { newVal in
                            rounds = newVal
                            haptic()
                            syncValue()
                        }
                    ),
                    in: 1...Double(maxRounds),
                    step: 1
                )
                .tint(themeGradient)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else {
            VStack(spacing: 24) {
                sliderRow(label: "Minutes", value: $minutes, range: 0...Double(maxMinutes))
                sliderRow(label: "Seconds", value: $seconds, range: 0...60)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    /// A single row with a label, a Slider, and a numeric display
    private func sliderRow(label: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.headline.weight(.medium))
                .foregroundColor(themeColor)
                .frame(width: 80, alignment: .leading)

            Slider(
                value: Binding(
                    get: { value.wrappedValue },
                    set: { newVal in
                        value.wrappedValue = newVal
                        haptic()
                        syncValue()
                    }
                ),
                in: range,
                step: 1
            )
            .tint(themeGradient)

            Text("\(Int(value.wrappedValue))")
                .font(.headline)
                .foregroundColor(themeColor)
                .frame(width: 40, alignment: .trailing)
        }
    }

    /// A preview text showing the current number of “minutes+seconds” or “rounds”
    private var previewView: some View {
        Text(livePreviewText)
            .font(.title3.weight(.semibold))
            .foregroundColor(themeColor)
            .padding(.top, 8)
    }

    /// Used to trigger the spring animation whenever the slider or rounds change
    private var animationTrigger: Int {
        switch type {
        case .rounds: return Int(rounds)
        default:      return Int(minutes * 60 + seconds)
        }
    }

    /// Haptic feedback on slider drag
    private func haptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// The text that updates as the user moves sliders
    private var livePreviewText: String {
        switch type {
        case .rounds:
            return "Selected: \(Int(rounds)) rounds"
        default:
            return "Selected: \(Int(minutes))m \(Int(seconds))s"
        }
    }

    /// Synchronize our @Binding<Int> “value” whenever the sliders change
    private func syncValue() {
        switch type {
        case .rounds:
            value = Int(rounds)
        default:
            value = Int(minutes) * 60 + Int(seconds)
        }
    }
}

// ───────────────────────────────────────────────────────────
//  Below we add exactly one “extension PickerType” to supply `iconName`.
//  Do NOT re‑declare the entire enum here—just this extension.
// ───────────────────────────────────────────────────────────

private extension PickerType {
    var iconName: String {
        switch self {
        case .getReady: return "bolt.fill"
        case .rounds:   return "repeat"
        case .work:     return "flame.fill"
        case .rest:     return "leaf.fill"
        }
    }
}

