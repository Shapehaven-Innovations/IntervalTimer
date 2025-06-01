/// AnalyticsView.swift
//
//  AnalyticsView.swift
//  IntervalTimer
//  Interactive analytics with Charts + Calories Burned over Time
//  Refactored 05/31/25 to improve card visibility in Dark Mode
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // ── Data ──────────────────────────────────
    @State private var history: [SessionRecord] = []
    @State private var intentions: [IntentRecord] = []
    @State private var selectedState: String? = nil

    // ── Goals & Onboarding ────────────────────
    @AppStorage("dailyGoal")   private var dailyGoal:   Int    = 1
    @AppStorage("weeklyGoal")  private var weeklyGoal:  Int    = 7
    @AppStorage("monthlyGoal") private var monthlyGoal: Int    = 30

    @AppStorage("userSex")    private var userSex:    String = ""
    @AppStorage("userHeight") private var userHeight: Int    = 0
    @AppStorage("userWeight") private var userWeight: Int    = 0
    @AppStorage("weightUnit") private var weightUnit: String = "kg"

    // ── Timeframe Picker ─────────────────────
    private enum Timeframe: String, CaseIterable, Identifiable {
        case week    = "Week"
        case month   = "Month"
        case quarter = "Quarter"
        var id: String { rawValue }
    }
    @State private var selectedTimeframe: Timeframe = .month

    // ── Computed Metrics ──────────────────────
    private var totalSessions: Int {
        history.count
    }

    private var daysCompleted: Int {
        Set(history.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    private var counts: (today: Int, week: Int, month: Int) {
        let calendar = Calendar.current
        let todayCount = history.filter { calendar.isDateInToday($0.date) }.count
        let weekStart  = calendar.date(byAdding: .day,   value: -7,  to: Date())!
        let weekCount  = history.filter { $0.date >= weekStart }.count
        let monthStart = calendar.date(byAdding: .month, value: -1, to: Date())!
        let monthCount = history.filter { $0.date >= monthStart }.count
        return (todayCount, weekCount, monthCount)
    }

    private var intentionDistribution: [(state: String, count: Int)] {
        Dictionary(grouping: intentions, by: \.state)
            .mapValues(\.count)
            .map { (state: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    // ── Weight in Kilograms ───────────────────
    private var userWeightKg: Double {
        weightUnit == "lbs"
            ? Double(userWeight) / 2.20462
            : Double(userWeight)
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Onboarding Summary ─────────────────
                    HStack(spacing: 12) {
                        MetricCard(
                            title: "Sex",
                            value: userSex
                        )
                        MetricCard(
                            title: "Height",
                            value: "\(userHeight) cm"
                        )
                        MetricCard(
                            title: "Weight",
                            value: "\(userWeight) \(weightUnit)"
                        )
                    }
                    .padding(.horizontal)

                    // ── Overview ──────────────────────────
                    HStack(spacing: 12) {
                        MetricCard(
                            title: "Sessions",
                            value: "\(totalSessions)"
                        )
                        MetricCard(
                            title: "Days Done",
                            value: "\(daysCompleted)"
                        )
                    }
                    .padding(.horizontal)

                    // ── Calories Burned Chart ──────────────
                    caloriesSection

                    // ── Intentions Analysis + Drill‑down ─
                    intentionSection

                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                loadHistory()
                loadIntentions()
            }
        }
        .interactiveDismissDisabled(false)
        .preferredColorScheme(colorScheme)
    }

    // MARK: Calories Section
    private var caloriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calories Burned Over Time")
                .font(.headline)
                .padding(.horizontal)

            // Picker to choose Week / Month / Quarter
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Chart
            Chart {
                ForEach(computeDataPoints(), id: \.label) { point in
                    BarMark(
                        x: .value("Period", point.label),
                        y: .value("Calories", point.calories)
                    )
                    .foregroundStyle(.blue.gradient)
                    .annotation(position: .top) {
                        Text("\(point.calories)")
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxisLabel("Timeframe: \(selectedTimeframe.rawValue)")
            .chartYAxisLabel("Calories (kcal)")
            .frame(height: 260)
            .padding(.horizontal)
        }
    }

    // MARK: Compute Data Points
    /// Returns an array of DataPoint (label, calories) for the chosen timeframe.
    private func computeDataPoints() -> [DataPoint] {
        switch selectedTimeframe {
        case .week:
            return computeLastWeekByDay()
        case .month:
            return computeLastMonthByWeek()
        case .quarter:
            return computeLastQuarterByMonth()
        }
    }

    /// DataPoint model for chart entries
    private struct DataPoint {
        let label: String
        let calories: Int
    }

    // ── 1) Last 7 Days, Grouped by Day ─────────────────────
    private func computeLastWeekByDay() -> [DataPoint] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        var results: [DataPoint] = []

        for offset in stride(from: 6, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: todayStart) else {
                continue
            }
            let dayLabel = DateFormatter.localizedString(
                from: date,
                dateStyle: .short,
                timeStyle: .none
            ) // e.g. "5/24/25"

            let dayCalories = history
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .map { calculateCalories(for: $0) }
                .reduce(0, +)

            results.append(DataPoint(label: dayLabel, calories: dayCalories))
        }
        return results
    }

    // ── 2) Last 30 Days, Grouped by Week ───────────────────
    private func computeLastMonthByWeek() -> [DataPoint] {
        let calendar = Calendar.current
        let today = Date()
        guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) else {
            return []
        }

        // Find the start of the week containing monthAgo
        var weekStartDate = calendar.dateInterval(of: .weekOfYear, for: monthAgo)!.start
        var results: [DataPoint] = []

        while weekStartDate <= today {
            let weekLabel = DateFormatter.localizedString(
                from: weekStartDate,
                dateStyle: .medium,
                timeStyle: .none
            ) // e.g. "May 1, 25"

            guard let nextWeek = calendar.date(byAdding: .day, value: 7, to: weekStartDate) else {
                break
            }

            let weekCalories = history
                .filter { $0.date >= weekStartDate && $0.date < nextWeek }
                .map { calculateCalories(for: $0) }
                .reduce(0, +)

            results.append(DataPoint(label: weekLabel, calories: weekCalories))
            weekStartDate = nextWeek
        }
        return results
    }

    // ── 3) Last 3 Months, Grouped by Month ─────────────────
    private func computeLastQuarterByMonth() -> [DataPoint] {
        let calendar = Calendar.current
        let today = Date()
        guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: today) else {
            return []
        }

        var results: [DataPoint] = []
        var monthIteratorDate = threeMonthsAgo

        while monthIteratorDate <= today {
            let monthIndex = calendar.component(.month, from: monthIteratorDate) - 1
            let monthName = DateFormatter().monthSymbols[monthIndex]
            let year = calendar.component(.year, from: monthIteratorDate)
            let monthLabel = "\(monthName) \(year)" // e.g. "Mar 2025"

            guard let monthInterval = calendar.dateInterval(of: .month, for: monthIteratorDate) else {
                break
            }

            let monthCalories = history
                .filter { $0.date >= monthInterval.start && $0.date < monthInterval.end }
                .map { calculateCalories(for: $0) }
                .reduce(0, +)

            results.append(DataPoint(label: monthLabel, calories: monthCalories))

            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthIteratorDate) else {
                break
            }
            monthIteratorDate = nextMonth
        }
        return results
    }

    // MARK: Calorie Calculation
    /// Estimates calories burned for a session using MET=8:
    ///     cals = 0.0175 × MET × weight (kg) × duration (minutes)
    private func calculateCalories(for session: SessionRecord) -> Int {
        let totalWorkSeconds = session.timerDuration * session.sets
        let minutes = Double(totalWorkSeconds) / 60.0
        let met: Double = 8.0
        let cals = 0.0175 * met * userWeightKg * minutes
        return Int(round(cals))
    }

    // MARK: Intentions Section
    private var intentionSection: some View {
        let data = intentionDistribution

        return VStack(alignment: .leading, spacing: 8) {
            Text("Intentions Analysis")
                .font(.headline)
                .padding(.horizontal)

            if data.isEmpty {
                Text("No intentions recorded yet.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                Chart {
                    ForEach(data, id: \.state) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.5),
                            angularInset: 1
                        )
                        .foregroundStyle(by: .value("State", item.state))
                    }
                }
                .chartLegend(.visible)
                .frame(height: 240)
                .padding(.horizontal)

                Picker("Filter by Intention", selection: $selectedState) {
                    Text("All").tag(String?.none)
                    ForEach(data.map(\.state), id: \.self) { state in
                        let count = data.first { $0.state == state }!.count
                        Text("\(state) (\(count))")
                            .tag(Optional(state))
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
            }

            if let state = selectedState {
                Text("Sessions tagged “\(state)”")
                    .font(.subheadline).bold()
                    .padding(.horizontal)

                ForEach(history.filter { $0.intention == state }) { rec in
                    HStack {
                        Text(rec.name)
                        Spacer()
                        Text(rec.date, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }

                Button("Clear Filter") {
                    selectedState = nil
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: Data Loading
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        }
    }

    private func loadIntentions() {
        if let data = UserDefaults.standard.data(forKey: "intentionsHistory"),
           let decoded = try? JSONDecoder().decode([IntentRecord].self, from: data) {
            intentions = decoded.sorted { $0.date > $1.date }
        }
    }
}


// MARK: — MetricCard

private struct MetricCard: View {
    let title: String
    let value: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                // Use secondarySystemBackground so that in Dark Mode the card is slightly lighter than its surroundings.
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.7)
                : Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}


// MARK: — Preview

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnalyticsView()
                .preferredColorScheme(.light)
            AnalyticsView()
                .preferredColorScheme(.dark)
        }
    }
}

