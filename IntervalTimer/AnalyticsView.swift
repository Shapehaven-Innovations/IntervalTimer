// AnalyticsView.swift
// IntervalTimer
// Tracks summary + compares against goals

import SwiftUI

struct AnalyticsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var history: [SessionRecord] = []

    @AppStorage("dailyGoal")   private var dailyGoal:   Int = 1
    @AppStorage("weeklyGoal")  private var weeklyGoal:  Int = 7
    @AppStorage("monthlyGoal") private var monthlyGoal: Int = 30

    private var totalSessions: Int { history.count }
    private var daysCompleted:  Int {
        Set(history.map { Calendar.current.startOfDay(for: $0.date) }).count
    }
    private var todayCount: Int {
        history.filter { Calendar.current.isDateInToday($0.date) }.count
    }
    private var weekCount: Int {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return history.filter { $0.date >= start }.count
    }
    private var monthCount: Int {
        let start = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return history.filter { $0.date >= start }.count
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overview")) {
                    HStack {
                        Text("Total Sessions")
                        Spacer()
                        Text("\(totalSessions)").bold()
                    }
                    HStack {
                        Text("Days Completed")
                        Spacer()
                        Text("\(daysCompleted)").bold()
                    }
                }

                Section(header: Text("Progress vs Goals")) {
                    ProgressRow(title: "Today",
                                current: todayCount,
                                goal: dailyGoal)
                    ProgressRow(title: "Week",
                                current: weekCount,
                                goal: weeklyGoal)
                    ProgressRow(title: "Month",
                                current: monthCount,
                                goal: monthlyGoal)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Analytics")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear(perform: loadHistory)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder()
             .decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        }
    }
}

private struct ProgressRow: View {
    let title: String, current: Int, goal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(current)/\(goal)")
                    .bold()
            }
            ProgressView(value: Double(min(current, goal)),
                         total: Double(goal))
                .scaleEffect(y: 2, anchor: .center)
        }
        .padding(.vertical, 4)
    }
}

