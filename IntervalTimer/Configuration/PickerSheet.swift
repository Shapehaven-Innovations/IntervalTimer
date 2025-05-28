///
//  PickerSheet.swift
//  IntervalTimer
//  Modernized duration picker in minutes & seconds
//  Updated 05/28/25
//

import SwiftUI

/// A modal sheet that lets the user pick durations or rounds with an interactive, animated UI.
struct PickerSheet: View {
    let type: PickerType
    @Binding var value: Int

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    private let maxSeconds = 300
    private let maxRounds = 20
    private var maxMinutes: Int { maxSeconds / 60 }

    // Internal state for sliders/dials
    @State private var minutes: Double
    @State private var seconds: Double
    @State private var rounds: Double

    // Gradient for tinting
    private var themeGradient: LinearGradient {
        let colors = [themeColor, themeColor.opacity(0.7)]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // Solid theme color
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
        // Initialize state from binding value
        let initial = min(max(value.wrappedValue, 1), maxSeconds)
        _minutes = State(initialValue: Double(initial / 60))
        _seconds = State(initialValue: Double(initial % 60))
        _rounds  = State(initialValue: Double(min(max(value.wrappedValue, 1), maxRounds)))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                themeColor.opacity(0.05).ignoresSafeArea()

                VStack(spacing: 32) {
                    headerView

                    cardView
                        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: animationTrigger)

                    previewView

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
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
        .environment(\.colorScheme, .light)
    }

    /// Header with dynamic gradient text and icon
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

    /// Main interactive card (sliders or rounds)
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

    /// Row with label and slider
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

    /// Preview of current selection
    private var previewView: some View {
        Text(livePreviewText)
            .font(.title3.weight(.semibold))
            .foregroundColor(themeColor)
            .padding(.top, 8)
    }

    /// Determines what to animate
    private var animationTrigger: Int {
        switch type {
        case .rounds: return Int(rounds)
        default: return Int(minutes * 60 + seconds)
        }
    }

    /// Haptic feedback on slider drag
    private func haptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Text for live preview
    private var livePreviewText: String {
        switch type {
        case .rounds:
            return "Selected: \(Int(rounds)) rounds"
        default:
            return "Selected: \(Int(minutes))m \(Int(seconds))s"
        }
    }

    /// Sync binding value based on picker type
    private func syncValue() {
        switch type {
        case .rounds:
            value = Int(rounds)
        default:
            value = Int(minutes) * 60 + Int(seconds)
        }
    }
}

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

#if DEBUG
struct PickerSheet_Previews: PreviewProvider {
    @State static var tmp = 90
    static var previews: some View {
        Group {
            PickerSheet(type: .getReady, value: $tmp)
            PickerSheet(type: .rounds, value: $tmp)
            PickerSheet(type: .work, value: $tmp)
            PickerSheet(type: .rest, value: $tmp)
        }
        .environmentObject(ThemeManager.shared)
    }
}
#endif
