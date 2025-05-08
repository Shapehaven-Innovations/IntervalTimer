// AnalyticsView.swift
// IntervalTimer
// Tracks session history, displays overview
//

import SwiftUI

struct AnalyticsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var history: [SessionRecord] = []

    private var daysCompleted: Int {
        Set(history.map { Calendar.current.startOfDay(for: $0.date) }).count
    }
    private var totalSessions: Int {
        history.count
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overview").font(.headline)) {
                    HStack {
                        Text("Days Sessions Completed:")
                        Spacer()
                        Text("\(daysCompleted)").bold()
                    }
                    HStack {
                        Text("Total Sessions:")
                        Spacer()
                        Text("\(totalSessions)").bold()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") { clearHistory() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .onAppear(perform: loadHistory)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        } else {
            history = []
        }
    }

    private func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "sessionHistory")
    }
}

