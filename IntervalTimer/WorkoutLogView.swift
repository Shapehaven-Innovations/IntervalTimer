// WorkoutLogView.swift
// IntervalTimer
// Detailed list of every session

import SwiftUI

struct WorkoutLogView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var history: [SessionRecord] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(history) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.name.isEmpty ? "Unnamed Workout" : record.name)
                            .font(.headline)

                        Text(record.date, style: .date) +
                        Text(" ") +
                        Text(record.date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Text("Work: \(format(record.timerDuration))")
                            Spacer()
                            Text("Rest: \(format(record.restDuration))")
                            Spacer()
                            Text("Sets: \(record.sets)")
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Workout Log")
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

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
