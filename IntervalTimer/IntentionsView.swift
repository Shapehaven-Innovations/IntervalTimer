// IntentionsView.swift
// IntervalTimer
// Log your intention before starting a session

import SwiftUI

struct IntentionsView: View {
    @Environment(\.presentationMode) private var presentationMode

    // MARK: – Selection State
    @State private var selectedMind: StateOfMind?
    @State private var timeGoal: TimeGoal = .equal30
    @State private var intensity: Intensity = .medium
    @State private var workoutMindset: WorkoutMindset = .completion

    // Day of week from device locale
    private var currentDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            Form {
                // State of Mind
                Section(header: Text("STATE OF MIND")) {
                    LazyVGrid(
                        columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2),
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
                                                  ? Color.accentColor.opacity(0.2)
                                                  : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                }

                // Session Time Goal
                Section(header: Text("SESSION TIME GOAL")) {
                    Picker("Time Goal", selection: $timeGoal) {
                        ForEach(TimeGoal.allCases) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.clear) // remove default capsule
                }

                // Rated Intensity
                Section(header: Text("RATED INTENSITY")) {
                    Picker("Intensity", selection: $intensity) {
                        ForEach(Intensity.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.clear)
                }

                // Day of Week
                Section(header: Text("DAY OF WEEK")) {
                    Text(currentDay)
                        .foregroundColor(.secondary)
                }

                // Workout Mindset
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
                                                  ? Color.accentColor.opacity(0.2)
                                                  : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Intentions")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    // TODO: persist selections (e.g. UserDefaults or your data model)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: – Supporting Enums

enum StateOfMind: String, CaseIterable {
    case Calm, Anxious, Focused, Confused, Happy, Sad, Angry, Curious
}

enum TimeGoal: String, CaseIterable, Identifiable {
    case greater30 = "> 30 min"
    case less30    = "< 30 min"
    case equal30   = "= 30 min"
    var id: String { rawValue }
}

enum Intensity: String, CaseIterable, Identifiable {
    case easy, medium, hard
    var id: String { rawValue }
}

enum WorkoutMindset: String, CaseIterable, Identifiable {
    case completion   = "Completion Mindset"
    case performance  = "Performance Driven"
    case appreciation = "Effort Appreciation"
    var id: String { rawValue }
}

struct IntentionsView_Previews: PreviewProvider {
    static var previews: some View {
        IntentionsView()
    }
}

