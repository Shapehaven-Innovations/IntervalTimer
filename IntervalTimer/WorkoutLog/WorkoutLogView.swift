// WorkoutLogView.swift
// IntervalTimer
// Detailed list of every session, now with live theming from ThemeManager

import SwiftUI

struct WorkoutLogView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var history: [SessionRecord] = []
    @State private var showingClearAlert = false

    // MARK: – Pull in user info from Onboarding
    @AppStorage("userWeight") private var userWeight: Int = 70
    @AppStorage("weightUnit")  private var weightUnit: String = "kg"
    @AppStorage("userHeight")  private var userHeight: Int    = 170

    /// Converts stored weight into kilograms
    private var weightKg: Double {
        weightUnit == "lbs"
            ? Double(userWeight) / 2.20462
            : Double(userWeight)
    }

    /// Simple MET‐based calorie estimate (MET = 8)
    private func caloriesBurned(for record: SessionRecord) -> Int {
        let workSeconds = record.timerDuration * record.sets
        let minutes     = Double(workSeconds) / 60.0
        let met: Double = 8.0
        let cals = 0.0175 * met * weightKg * minutes
        return Int(round(cals))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, record in
                        WorkoutCard(
                            record:   record,
                            index:    index,
                            calories: caloriesBurned(for: record)
                        )
                        .environmentObject(themeManager)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Workout Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") { showingClearAlert = true }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .alert("Clear Workout Log?", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { clearHistory() }
            } message: {
                Text("This cannot be undone.")
            }
            .onAppear(perform: loadHistory)
        }
    }

    // MARK: – Data

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        }
    }

    private func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "sessionHistory")
    }
}

private struct WorkoutCard: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let record:   SessionRecord
    let index:    Int
    let calories: Int

    /// Light background tint from the theme
    private var backgroundTint: Color {
        let palette = themeManager.selected.cardBackgrounds
        return palette[index % palette.count].opacity(0.1)
    }

    /// Slightly stronger shadow tint
    private var shadowTint: Color {
        let palette = themeManager.selected.cardBackgrounds
        return palette[index % palette.count].opacity(0.2)
    }

    /// Accent color (for labels)
    private var accent: Color {
        themeManager.selected.accent
    }

    private var displayName: String {
        let trimmed = record.name.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { return trimmed }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd"
        return fmt.string(from: record.date)
    }

    private var subtitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        return fmt.string(from: record.date)
    }

    private var totalTimeString: String {
        let restTotal = max(0, record.restDuration * (record.sets - 1))
        let totalSec  = record.timerDuration * record.sets + restTotal
        let m = totalSec / 60, s = totalSec % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(displayName).font(.headline)
                Spacer()
                Text(totalTimeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 24) {
                Label(formatTime(record.timerDuration), systemImage: "flame.fill")
                Label(formatTime(record.restDuration),    systemImage: "bed.double.fill")
                Label("\(record.sets)x",                  systemImage: "repeat.circle.fill")
                Label("\(calories) kcal",                 systemImage: "figure.walk")
            }
            .font(.footnote)
            .foregroundColor(accent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundTint)
        )
        .shadow(color: shadowTint, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct WorkoutLogView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutLogView()
            .environmentObject(ThemeManager.shared)
    }
}

