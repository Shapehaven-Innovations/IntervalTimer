//
//  WorkoutLogView.swift
//  IntervalTimer
//  Updated 05/29/25: use system large title, full file with WorkoutCard
//

import SwiftUI

struct WorkoutLogView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    /// Mirror your global Dark Mode toggle
    @AppStorage("useDarkMode") private var useDarkMode: Bool = false

    @State private var history: [SessionRecord] = []
    @State private var showingClearAlert = false
    @State private var showingAnalytics = false

    // MARK: – Onboarding user info
    @AppStorage("userWeight") private var userWeight: Int = 70
    @AppStorage("weightUnit")  private var weightUnit: String = "kg"

    /// Convert to kilograms
    private var weightKg: Double {
        weightUnit == "lbs"
            ? Double(userWeight) / 2.20462
            : Double(userWeight)
    }

    /// MET‐based calorie estimate (MET = 8)
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
                    ForEach(Array(history.enumerated()), id: \.element.id) { idx, record in
                        WorkoutCard(
                            record:   record,
                            index:    idx,
                            calories: caloriesBurned(for: record)
                        )
                        .environmentObject(themeManager)
                    }
                }
                .padding(.top, 20)    // space under the large title
                .padding(.bottom, 16) // bottom breathing room
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Workout Log")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Three-dot menu on the right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Clear All", role: .destructive) {
                            showingClearAlert = true
                        }
                        Button("Analytics") {
                            showingAnalytics = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.title2)
                            .foregroundColor(themeManager.selected.accent)
                    }
                }
            }
            .alert("Clear Workout Log?", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { clearHistory() }
            } message: {
                Text("This cannot be undone.")
            }
            .sheet(isPresented: $showingAnalytics) {
                AnalyticsView()
                    .environmentObject(themeManager)
            }
            .onAppear(perform: loadHistory)
        }
        .preferredColorScheme(useDarkMode ? .dark : .light)
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
    @Environment(\.colorScheme) private var colorScheme

    let record:   SessionRecord
    let index:    Int
    let calories: Int

    private var baseColor: Color {
        themeManager.selected.cardBackgrounds[
            index % themeManager.selected.cardBackgrounds.count
        ]
    }
    private var backgroundTint: Color {
        baseColor.opacity(colorScheme == .dark ? 0.30 : 0.10)
    }
    private var shadowTint: Color {
        baseColor.opacity(colorScheme == .dark ? 0.40 : 0.20)
    }
    private var labelColor: Color {
        colorScheme == .dark ? .white : themeManager.selected.accent
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
                Text(displayName)
                    .font(.headline)
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
            .foregroundColor(labelColor)
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

