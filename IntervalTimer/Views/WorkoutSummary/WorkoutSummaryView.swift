//
//  WorkoutSummaryView.swift
//  IntervalTimer
//
//  Shows the “Workout Complete!” summary. When the user taps “Done”,
//  it calls `onDone()` to close both this sheet and the parent TimerView.
//

import SwiftUI
import MessageUI

//
//  A lightweight message‐composer for “Share”:
//
struct MessageComposer: UIViewControllerRepresentable {
    let body: String

    static var canSendText: Bool {
        MFMessageComposeViewController.canSendText()
    }

    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = body
        controller.messageComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: MessageComposer
        init(parent: MessageComposer) { self.parent = parent }

        func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MessageComposeResult
        ) {
            controller.dismiss(animated: true) {
                // When the user finishes messaging, also dismiss the SwiftUI sheet that wrapped this view:
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


struct WorkoutSummaryView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // MARK: – Inputs
    let record: SessionRecord
    let calories: Int

    /// Called when the user taps “Done.”
    /// The parent (TimerView) will implement this to hide both sheets.
    let onDone: () -> Void

    @State private var isShowingMessageComposer = false

    // MARK: – Date & Time Formatting Helpers
    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .full
        fmt.timeStyle = .short
        return fmt.string(from: record.date)
    }

    private var totalTimeString: String {
        // Sum up all (work + rest) segments
        let restTotal = max(0, record.restDuration * (record.sets - 1))
        let totalSec  = record.timerDuration * record.sets + restTotal
        let minutes = totalSec / 60
        let seconds = totalSec % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var shareText: String {
        var base = """
        I just completed “\(record.name)” on \(formattedDate).
        Duration: \(totalTimeString)
        Calories burned: \(calories) kcal
        """
        if let intent = record.intention, !intent.isEmpty {
            base += "\nIntention: \(intent)"
        }
        return base
    }

    var body: some View {
        ZStack {
            // Fill entire background with the theme’s background color
            themeManager.selected.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                //
                //  ── Header ──
                //
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    themeManager.selected.accent.opacity(0.8),
                                    themeManager.selected.accent
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(1.2)
                        .shadow(
                            color: themeManager.selected.accent.opacity(0.5),
                            radius: 10,
                            x: 0,
                            y: 5
                        )

                    // Always force this text to white so it’s legible on any background
                    Text("Workout Complete!")
                        .font(.largeTitle.weight(.black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                //
                //  ── Summary Cards ──
                //
                VStack(spacing: 16) {
                    SummaryCardView(
                        iconName: "flame.fill",
                        title: "Calories Burned",
                        value: "\(calories) kcal",
                        cardColor: themeManager.selected.cardBackgrounds[2]
                    )

                    SummaryCardView(
                        iconName: "timer",
                        title: "Total Time",
                        value: totalTimeString,
                        cardColor: themeManager.selected.cardBackgrounds[3]
                    )

                    SummaryCardView(
                        iconName: "calendar",
                        title: "Date",
                        value: formattedDate,
                        cardColor: themeManager.selected.cardBackgrounds[0]
                    )

                    if let intention = record.intention, !intention.isEmpty {
                        SummaryCardView(
                            iconName: "lightbulb.fill",
                            title: "Intention",
                            value: intention,
                            cardColor: themeManager.selected.cardBackgrounds[7]
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()

                //
                //  ── Buttons: “Done” + “Share” ──
                //
                HStack(spacing: 16) {
                    // DONE Button
                    Button(action: {
                        onDone()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    // secondarySystemBackground is white in Light Mode, dark gray in Dark Mode
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                            // Use the system label color (black on white, white on dark)
                            .foregroundColor(Color(.label))
                    }

                    // SHARE Button
                    Button(action: {
                        isShowingMessageComposer = true
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Share")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(themeManager.selected.accent)
                        )
                        .foregroundColor(.white)
                    }
                    .disabled(!MessageComposer.canSendText)
                    .opacity(MessageComposer.canSendText ? 1.0 : 0.5)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $isShowingMessageComposer) {
            if MessageComposer.canSendText {
                MessageComposer(body: shareText)
            } else {
                Text("Your device is not configured to send Messages.")
                    .font(.body)
                    .padding()
            }
        }
    }
}


/// A single row of the summary cards (icon + title + value).
private struct SummaryCardView: View {
    let iconName: String
    let title: String
    let value: String
    let cardColor: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .padding(12)
                .background(Circle().fill(cardColor))

            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                // Allow the value text (e.g., long date/time) to wrap onto multiple lines:
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                    // Ensures the text can expand vertically rather than truncating:
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                // secondarySystemBackground is white in Light Mode, dark gray in Dark Mode
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.6)
                : Color.black.opacity(0.1),
            radius: 5,
            x: 0,
            y: 3
        )
    }
}

