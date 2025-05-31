//
//  IntentionsView.swift
//  IntervalTimer
//  Paged quiz UI for capturing user intention
//
//  Refactored 05/31/25 to support Light/Dark Mode via system colors
//

import SwiftUI

// MARK: Supporting Enums

enum StateOfMind: String, CaseIterable {
    case Calm, Anxious, Focused, Confused, Happy, Sad, Angry, Curious
}

enum TimeGoal: String, CaseIterable, Identifiable {
    case greater30 = "> 30 min", less30 = "< 30 min", equal30 = "= 30 min"
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

// MARK: Question Model

private struct Question {
    let text: String
    let options: [String]
}

// MARK: IntentionsView

struct IntentionsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme

    /// Callback with the chosen intention (only the first answer is ever passed back)
    let onSave: (String) -> Void

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

    init(onSave: @escaping (String) -> Void) {
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
            Spacer()
            nextButton
        }
        // Use systemBackground so it flips automatically in Light/Dark Mode
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: – Header

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
                    .foregroundColor(Color(.label))
            }

            Spacer()

            Text("Set Your Intention")
                .font(.headline)
                .foregroundColor(Color(.label))

            Spacer()

            Button {
                // (Optional) Help action
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
    }

    // MARK: – Content (Question + Options)

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Question \(currentStep + 1)/\(questions.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color.secondary)
                .padding(.horizontal)

            Text(questions[currentStep].text)
                .font(.title3.weight(.semibold))
                .foregroundColor(Color.primary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(questions[currentStep].options.indices, id: \.self) { idx in
                    OptionRow(
                        text: questions[currentStep].options[idx],
                        isSelected: selectionIndex == idx,
                        accent: Color.accentColor
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

    // MARK: – Next / Save Button

    private var nextButton: some View {
        Button {
            if currentStep < questions.count - 1 {
                // Move to the next question; restore previous selection (if any)
                currentStep += 1
                selectionIndex = answers[currentStep]
            } else {
                // Persist only the first answer (state-of-mind)
                let chosenStateIndex = answers[0] ?? 0
                let state = questions[0].options[chosenStateIndex]

                // 1) Load existing history from UserDefaults
                var all: [IntentRecord] = []
                if
                    let data = UserDefaults.standard.data(forKey: "intentionsHistory"),
                    let decoded = try? JSONDecoder().decode([IntentRecord].self, from: data)
                {
                    all = decoded
                }

                // 2) Append the new record
                let newRecord = IntentRecord(date: Date(), state: state)
                all.append(newRecord)

                // 3) Save back to UserDefaults
                if let enc = try? JSONEncoder().encode(all) {
                    UserDefaults.standard.set(enc, forKey: "intentionsHistory")
                }

                // 4) Notify parent
                onSave(state)

                // 5) Dismiss
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            Text(currentStep < questions.count - 1 ? "Next" : "Save")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .disabled(selectionIndex == nil)
        .opacity(selectionIndex == nil ? 0.5 : 1)
    }
}

// MARK: – Single-row Option

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
                .foregroundColor(isSelected ? .white : Color.primary)
                .font(.body)

            Spacer()
        }
        .padding()
        .background(
            Group {
                if isSelected {
                    accent
                } else {
                    Color(.secondarySystemBackground)
                }
            }
        )
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: – Preview

struct IntentionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IntentionsView { _ in }
                .preferredColorScheme(.light)

            IntentionsView { _ in }
                .preferredColorScheme(.dark)
        }
    }
}

