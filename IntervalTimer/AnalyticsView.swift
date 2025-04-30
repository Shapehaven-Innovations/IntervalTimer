//
// AnalyticsView.swift
// IntervalTimer
// Tracks session history, displays overview and recent configurations
//

import SwiftUI

struct SessionRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let timerDuration: Int
    let restDuration: Int
    let sets: Int

    /// Initializes a new session record. `id` is auto-generated if not provided.
    init(id: UUID = UUID(), date: Date, timerDuration: Int, restDuration: Int, sets: Int) {
        self.id = id
        self.date = date
        self.timerDuration = timerDuration
        self.restDuration = restDuration
        self.sets = sets
    }
}

struct AnalyticsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var history: [SessionRecord] = []

    private var daysCompleted: Int {
        Set(history.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overview").font(.headline)) {
                    HStack {
                        Text("Days Sessions Completed:")
                        Spacer()
                        Text("\(daysCompleted)")
                            .bold()
                    }

                    HStack {
                        Text("Total Sessions:")
                        Spacer()
                        Text("\(history.count)")
                            .bold()
                    }
                }

                Section(header: Text("Recent Configurations").font(.headline)) {
                    if history.isEmpty {
                        Text("No session data available.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(history.prefix(5)) { record in
                            VStack(alignment: .leading) {
                                Text(record.date, style: .date)
                                Text("Work: \(record.timerDuration)s, Rest: \(record.restDuration)s, Sets: \(record.sets)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
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
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        }
    }
}

