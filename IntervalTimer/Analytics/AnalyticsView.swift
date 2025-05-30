//  AnalyticsView.swift
//  IntervalTimer
//  Interactive analytics with Charts + drill‑down by intention
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.dismiss) private var dismiss

    // ── Data ──────────────────────────────────
    @State private var history:    [SessionRecord] = []
    @State private var intentions: [IntentRecord]  = []
    @State private var selectedState: String?      = nil

    // ── Goals & Onboarding ────────────────────
    @AppStorage("dailyGoal")   private var dailyGoal:   Int    = 1
    @AppStorage("weeklyGoal")  private var weeklyGoal:  Int    = 7
    @AppStorage("monthlyGoal") private var monthlyGoal: Int    = 30

    @AppStorage("userSex")    private var userSex:    String = ""
    @AppStorage("userHeight") private var userHeight: Int    = 0
    @AppStorage("userWeight") private var userWeight: Int    = 0
    @AppStorage("weightUnit") private var weightUnit: String = "kg"

    // ── Computed Metrics ──────────────────────
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

    private var intentionDistribution: [(state: String, count: Int)] {
        Dictionary(grouping: intentions, by: \.state)
            .mapValues(\.count)
            .map { (state: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Onboarding Summary ─────────────────
                    HStack {
                        MetricCard(title: "Sex",    value: userSex)
                        MetricCard(title: "Height", value: "\(userHeight) cm")
                        MetricCard(title: "Weight", value: "\(userWeight) \(weightUnit)")
                    }
                    .padding(.horizontal)

                    // ── Overview ──────────────────────────
                    HStack {
                        MetricCard(title: "Sessions",  value: "\(totalSessions)")
                        MetricCard(title: "Days Done", value: "\(daysCompleted)")
                    }
                    .padding(.horizontal)

                    // ── Progress vs Goals ─────────────────
                    progressSection

                    // ── Intentions Analysis + Drill‑down ─
                    intentionSection

                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            // no Done button – rely on sheet’s swipe-to-dismiss
        }
        .interactiveDismissDisabled(false)
        .onAppear {
            loadHistory()
            loadIntentions()
        }
    }

    // MARK: Progress Chart
    private var progressSection: some View {
        let (today, week, month) = (counts.today, counts.week, counts.month)
        let (dGoal, wGoal, mGoal) = (dailyGoal, weeklyGoal, monthlyGoal)

        return VStack(alignment: .leading, spacing: 8) {
            Text("Progress vs Goals")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                BarMark(x: .value("Count", today), y: .value("Period", "Today"))
                BarMark(x: .value("Count", week),  y: .value("Period", "Week"))
                BarMark(x: .value("Count", month), y: .value("Period", "Month"))

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

    // MARK: Intentions & Drill‑down
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
                        Text("\(state) (\(data.first { $0.state == state }!.count))")
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

// MARK: MetricCard

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

