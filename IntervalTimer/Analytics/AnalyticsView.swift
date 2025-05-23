// AnalyticsView.swift
// IntervalTimer
// Modernized interactive analytics with Charts

import SwiftUI
import Charts

// MARK: – Intent Record

/// Records an intention set by the user.
/// Conforms to Codable so we can persist and load from UserDefaults.
struct IntentRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let state: String

    /// Convenience initializer for new records.
    init(date: Date, state: String) {
        self.id = UUID()
        self.date = date
        self.state = state
    }
}

// MARK: – Analytics View

struct AnalyticsView: View {
    @Environment(\.presentationMode) private var presentationMode

    // Session history
    @State private var history: [SessionRecord] = []
    // Intentions history
    @State private var intentions: [IntentRecord] = []

    // Goals
    @AppStorage("dailyGoal")   private var dailyGoal:   Int = 1
    @AppStorage("weeklyGoal")  private var weeklyGoal:  Int = 7
    @AppStorage("monthlyGoal") private var monthlyGoal: Int = 30

    // Onboarding info
    @AppStorage("userSex")    private var userSex:    String = ""
    @AppStorage("userHeight") private var userHeight: Int    = 0
    @AppStorage("userWeight") private var userWeight: Int    = 0
    @AppStorage("weightUnit") private var weightUnit: String = "kg"

    // Computed metrics
    private var totalSessions: Int { history.count }
    private var daysCompleted: Int {
        Set(history.map { Calendar.current.startOfDay(for: $0.date) }).count
    }
    private var counts: (today: Int, week: Int, month: Int) {
        let todayCount = history.filter { Calendar.current.isDateInToday($0.date) }.count
        let weekStart  = Calendar.current.date(byAdding: .day,   value: -7,  to: Date())!
        let weekCount  = history.filter { $0.date >= weekStart }.count
        let monthStart = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let monthCount = history.filter { $0.date >= monthStart }.count
        return (todayCount, weekCount, monthCount)
    }

    // Distribution of intentions by state
    private var intentionDistribution: [(state: String, count: Int)] {
        Dictionary(grouping: intentions, by: \.state)
            .mapValues(\.count)
            .map { (state: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Onboarding Summary
                    HStack {
                        MetricCard(title: "Sex",    value: userSex)
                        MetricCard(title: "Height", value: "\(userHeight) cm")
                        MetricCard(title: "Weight", value: "\(userWeight) \(weightUnit)")
                    }
                    .padding(.horizontal)

                    // MARK: Overview
                    HStack {
                        MetricCard(title: "Sessions",  value: "\(totalSessions)")
                        MetricCard(title: "Days Done", value: "\(daysCompleted)")
                    }
                    .padding(.horizontal)

                    // MARK: Progress vs Goals
                    progressSection

                    // MARK: Intentions Analysis
                    intentionSection

                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") { presentationMode.wrappedValue.dismiss() }
            )
            .onAppear {
                loadHistory()
                loadIntentions()
            }
        }
    }

    // MARK: – Progress Chart Subview

    private var progressSection: some View {
        // Break up into locals for compile‐time efficiency
        let today = counts.today
        let week  = counts.week
        let month = counts.month
        let dGoal = dailyGoal
        let wGoal = weeklyGoal
        let mGoal = monthlyGoal

        return VStack(alignment: .leading, spacing: 8) {
            Text("Progress vs Goals")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                // Actual counts
                BarMark(x: .value("Count", today), y: .value("Period", "Today"))
                BarMark(x: .value("Count", week),  y: .value("Period", "Week"))
                BarMark(x: .value("Count", month), y: .value("Period", "Month"))

                // Goal lines (span full height)
                RuleMark(x: .value("Goal", dGoal))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.red)

                RuleMark(x: .value("Goal", wGoal))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.red)

                RuleMark(x: .value("Goal", mGoal))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.red)
            }
            .chartXAxisLabel("Sessions")
            .frame(height: 200)
            .padding(.horizontal)
        }
    }

    // MARK: – Intentions Chart Subview

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
            }
        }
    }

    // MARK: – Data Loading

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

// MARK: – Reusable Metric Card

private struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

