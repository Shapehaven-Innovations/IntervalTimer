// IntentionsView.swift
// IntervalTimer
// Log your intention before starting a session (dynamic title)

import SwiftUI

struct IntentionsView: View {
    @Environment(\.presentationMode) private var presentationMode

    // MARK: – Selection State
    @State private var selectedMind:    StateOfMind?      = nil
    @State private var timeGoal:        TimeGoal          = .equal30
    @State private var intensity:       Intensity         = .medium
    @State private var workoutMindset:  WorkoutMindset    = .completion

    // MARK: – Computed Titles & Labels

    /// Returns “Morning Intention”, “Afternoon Intention” or “Evening Intention”
    private var greetingTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:     return "Morning Intention"
        case 12..<17:    return "Afternoon Intention"
        default:         return "Evening Intention"
        }
    }

    /// Day‑of‑week label
    private var currentDay: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: Date())
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()            // white background
                Form {
                    Section(header: Text("STATE OF MIND")) {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 12
                        ) {
                            ForEach(StateOfMind.allCases, id: \.self) { mind in
                                Button {
                                    selectedMind = mind
                                } label: {
                                    Text(mind.rawValue)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedMind == mind
                                                      ? mind.color.opacity(0.6)
                                                      : mind.color.opacity(0.2))
                                        )
                                        .foregroundColor(selectedMind == mind
                                                         ? .white
                                                         : mind.color.darker())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    Section(header: Text("SESSION TIME GOAL")) {
                        HStack(spacing: 12) {
                            ForEach(TimeGoal.allCases) { goal in
                                Button {
                                    timeGoal = goal
                                } label: {
                                    Text(goal.rawValue)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(timeGoal == goal
                                                      ? goal.color.opacity(0.6)
                                                      : Color(.systemGray6))
                                        )
                                        .foregroundColor(timeGoal == goal
                                                         ? .white
                                                         : goal.color)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }

                    Section(header: Text("RATED INTENSITY")) {
                        HStack(spacing: 12) {
                            ForEach(Intensity.allCases) { level in
                                Button {
                                    intensity = level
                                } label: {
                                    Text(level.rawValue.capitalized)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(intensity == level
                                                      ? level.color.opacity(0.6)
                                                      : Color(.systemGray6))
                                        )
                                        .foregroundColor(intensity == level
                                                         ? .white
                                                         : level.color)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }

                    Section(header: Text("DAY OF WEEK")) {
                        Text(currentDay)
                            .foregroundColor(.secondary)
                    }

                    Section(header: Text("WORKOUT MINDSET")) {
                        VStack(spacing: 12) {
                            ForEach(WorkoutMindset.allCases, id: \.self) { mindset in
                                Button {
                                    workoutMindset = mindset
                                } label: {
                                    Text(mindset.rawValue)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(workoutMindset == mindset
                                                      ? mindset.color.opacity(0.6)
                                                      : mindset.color.opacity(0.2))
                                        )
                                        .foregroundColor(workoutMindset == mindset
                                                         ? .white
                                                         : mindset.color.darker())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)  // remove form gray
            }
            .navigationTitle(greetingTitle)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // TODO: persist selections if you want
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: – Color Helper

extension Color {
    /// Darken by subtracting 0.2 from each component
    func darker() -> Color {
        let ui = UIColor(self)
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        ui.getRed(&r, green:&g, blue:&b, alpha:&a)
        return Color(
            red: Double(max(r-0.2, 0)),
            green: Double(max(g-0.2, 0)),
            blue: Double(max(b-0.2, 0)),
            opacity: Double(a)
        )
    }
}

// MARK: – Supporting Types

enum StateOfMind: String, CaseIterable {
    case Calm, Anxious, Focused, Confused, Happy, Sad, Angry, Curious

    /// Pull colors from your Theme.swift
    var color: Color {
        Theme.cardBackgrounds[
            StateOfMind.allCases.firstIndex(of: self) ?? 0
        ]
    }
}

enum TimeGoal: String, CaseIterable, Identifiable {
    case greater30 = "> 30 min", less30 = "< 30 min", equal30 = "= 30 min"
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .greater30: return .green
        case .less30:    return .red
        case .equal30:   return .blue
        }
    }
}

enum Intensity: String, CaseIterable, Identifiable {
    case easy, medium, hard
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
        }
    }
}

enum WorkoutMindset: String, CaseIterable, Identifiable {
    case completion   = "Completion Mindset"
    case performance  = "Performance Driven"
    case appreciation = "Effort Appreciation"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .completion:   return .mint
        case .performance:  return .purple
        case .appreciation: return .pink
        }
    }
}

// MARK: – Preview

struct IntentionsView_Previews: PreviewProvider {
    static var previews: some View {
        IntentionsView()
    }
}

