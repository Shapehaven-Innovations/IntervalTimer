//
//  WorkoutSummaryView.swift
//  IntervalTimer
//
//  Created by Your Name on 06/01/25.
//  Displays a celebratory summary after each completed workout.
//

import SwiftUI

struct WorkoutSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    /// The session record that was just completed & saved.
    let record: SessionRecord

    /// Computed calories based on weight & session info.
    let calories: Int

    /// Format a `Date` into a user‐friendly string.
    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .full
        fmt.timeStyle = .short
        return fmt.string(from: record.date)
    }

    /// Total workout time (including rest).
    private var totalTimeString: String {
        let restTotal = max(0, record.restDuration * (record.sets - 1))
        let totalSec  = record.timerDuration * record.sets + restTotal
        let minutes = totalSec / 60, seconds = totalSec % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            // Background color depends on theme
            themeManager.selected.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // ── Celebration Header ─────────────────────────
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [themeManager.selected.accent.opacity(0.8), themeManager.selected.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(1.2)
                        .shadow(color: themeManager.selected.accent.opacity(0.5), radius: 10, x: 0, y: 5)

                    Text("Workout Complete!")
                        .font(.largeTitle.weight(.black))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // ── Summary Cards ─────────────────────────────
                VStack(spacing: 16) {
                    SummaryCardView(
                        iconName: "flame.fill",
                        title: "Calories Burned",
                        value: "\(calories) kcal",
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

                // ── Dismiss / Share Buttons ───────────────────
                HStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.secondary.opacity(0.2))
                            )
                            .foregroundColor(.primary)
                    }

                    Button(action: {
                        shareSummary()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
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
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }

    /// Presents a share sheet with the summary text.
    private func shareSummary() {
        let summaryText = """
        I just completed “\(record.name)” on \(formattedDate).
        Duration: \(totalTimeString)
        Calories burned: \(calories) kcal
        \(record.intention.map { "Intention: \($0)" } ?? "")
        """
        let av = UIActivityViewController(activityItems: [summaryText], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
}

/// A small reusable card for each metric in the summary.
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
                .background(
                    Circle()
                        .fill(cardColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
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

#if DEBUG
struct WorkoutSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = SessionRecord(
            name: "Morning Burn",
            date: Date(),
            timerDuration: 60,
            restDuration: 30,
            sets: 5,
            intention: "Focused"
        )
        WorkoutSummaryView(record: sample, calories: 250)
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.light)

        WorkoutSummaryView(record: sample, calories: 250)
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
    }
}
#endif
