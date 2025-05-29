//
//  IntentionsView.swift
//  IntervalTimer
//  Refactored to a paged quiz UI matching latest design mockup
//

import SwiftUI

// MARK: – Supporting Enums

/// User’s state of mind options
enum StateOfMind: String, CaseIterable {
    case Calm, Anxious, Focused, Confused, Happy, Sad, Angry, Curious
}

/// Session duration goals
enum TimeGoal: String, CaseIterable, Identifiable {
    case greater30 = "> 30 min", less30 = "< 30 min", equal30 = "= 30 min"
    var id: String { rawValue }
}

/// Rated intensity
enum Intensity: String, CaseIterable, Identifiable {
    case easy, medium, hard
    var id: String { rawValue }
}

/// Workout mindset choices
enum WorkoutMindset: String, CaseIterable, Identifiable {
    case completion   = "Completion Mindset"
    case performance  = "Performance Driven"
    case appreciation = "Effort Appreciation"
    var id: String { rawValue }
}

// MARK: – Question Model

private struct Question {
    let text: String
    let options: [String]
}

// MARK: – IntentionsView

struct IntentionsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager

    // Paging state
    @State private var currentStep: Int = 0
    @State private var selectionIndex: Int? = nil
    @State private var answers: [Int?] = Array(repeating: nil, count: 4)

    // Four pages of questions
    private let questions: [Question] = [
        Question(
            text: "How are you feeling today?",
            options: StateOfMind.allCases.map { $0.rawValue }
        ),
        Question(
            text: "What session duration feels best?",
            options: TimeGoal.allCases.map { $0.rawValue }
        ),
        Question(
            text: "Choose your intensity:",
            options: Intensity.allCases.map { $0.rawValue.capitalized }
        ),
        Question(
            text: "Select your workout mindset:",
            options: WorkoutMindset.allCases.map { $0.rawValue }
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
            Spacer()
            nextButton
        }
        .background(themeManager.selected.backgroundColor.ignoresSafeArea())
    }

    // Header bar
    private var header: some View {
        HStack {
            Button {
                if currentStep == 0 {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    currentStep -= 1
                    selectionIndex = answers[currentStep]
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(themeManager.selected.accent)
            }

            Spacer()

            Text("Set Your Intention")
                .font(.headline)
                .foregroundColor(themeManager.selected.accent)

            Spacer()

            Button {
                // help tap
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(themeManager.selected.accent)
            }
        }
        .padding()
    }

    // Main question + options
    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Question \(currentStep + 1)/\(questions.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(themeManager.selected.accent.opacity(0.8))
                .padding(.horizontal)

            Text(questions[currentStep].text)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(questions[currentStep].options.indices, id: \.self) { idx in
                    OptionRow(
                        text: questions[currentStep].options[idx],
                        isSelected: selectionIndex == idx,
                        accent: themeManager.selected.accent
                    )
                    .onTapGesture {
                        selectionIndex = idx
                        answers[currentStep] = idx
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 16)
    }

    // Next/Save button
    private var nextButton: some View {
        Button {
            if currentStep < questions.count - 1 {
                currentStep += 1
                selectionIndex = answers[currentStep]
            } else {
                // Persist your answers here, then:
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            Text(currentStep < questions.count - 1 ? "Next" : "Save")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeManager.selected.accent)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
        }
        .disabled(selectionIndex == nil)
        .opacity(selectionIndex == nil ? 0.5 : 1)
    }
}

// Single‐row option with a radio circle
private struct OptionRow: View {
    let text: String
    let isSelected: Bool
    let accent: Color

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.white : accent, lineWidth: 2)
                    .frame(width: 24, height: 24)
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                }
            }

            Text(text)
                .foregroundColor(isSelected ? .white : .primary)
                .font(.body)

            Spacer()
        }
        .padding()
        .background(isSelected ? accent : Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct IntentionsView_Previews: PreviewProvider {
    static var previews: some View {
        IntentionsView()
            .environmentObject(ThemeManager.shared)
            .previewDevice("iPhone 14")
    }
}

