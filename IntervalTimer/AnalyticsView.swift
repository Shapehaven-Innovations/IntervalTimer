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

    init(id: UUID = UUID(), date: Date, timerDuration: Int, restDuration: Int, sets: Int) {
        self.id = id
        self.date = date
        self.timerDuration = timerDuration
        self.restDuration = restDuration
        self.sets = sets
    }
}

struct AnalyticsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var history: [SessionRecord] = []
    
    // AppStorage bindings so we can overwrite the live settings
    @AppStorage("timerDuration") private var timerDurationSetting: Int = 60
    @AppStorage("restDuration") private var restDurationSetting: Int = 30
    @AppStorage("sets") private var setsSetting: Int = 1
    
    // Alert for "Timer Set"
    @State private var showTimerSetAlert = false

    private var daysCompleted: Int {
        Set(history.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    var body: some View {
        NavigationView {
            List {
                // MARK: Overview + Reset
                Section(header: Text("Overview").font(.headline)) {
                    HStack {
                        Text("Days Sessions Completed:")
                        Spacer()
                        Text("\(daysCompleted)").bold()
                    }
                    HStack {
                        Text("Total Sessions:")
                        Spacer()
                        Text("\(history.count)").bold()
                    }
                }

                // MARK: Recent Configurations + Swipe-to-Delete + Tap-to-Apply
                Section(header: Text("Recent Configurations").font(.headline)) {
                    if history.isEmpty {
                        Text("No session data available.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(history.prefix(5)), id: \.id) { record in
                            Button {
                                // 2. Apply the configuration
                                timerDurationSetting = record.timerDuration
                                restDurationSetting = record.restDuration
                                setsSetting = record.sets
                                showTimerSetAlert = true
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(record.date, style: .date)
                                    Text("Work: \(record.timerDuration)s, Rest: \(record.restDuration)s, Sets: \(record.sets)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteConfigs)    // 3. Swipe left to delete
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Analytics")
            .toolbar {
                // 1. Reset analytics overview
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") { clearHistory() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            // 2. Alert when a configuration is applied
            .alert("Timer Set", isPresented: $showTimerSetAlert) {
                Button("OK", role: .cancel) {}
            }
            .onAppear(perform: loadHistory)
        }
    }

    // Load from UserDefaults
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        } else {
            history = []
        }
    }

    // Delete one or more configurations
    private func deleteConfigs(at offsets: IndexSet) {
        let toDelete = Array(history.prefix(5))
        for index in offsets {
            let record = toDelete[index]
            if let idx = history.firstIndex(where: { $0.id == record.id }) {
                history.remove(at: idx)
            }
        }
        saveHistory()
    }

    // Clear all history
    private func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "sessionHistory")
    }

    // Persist the updated history
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "sessionHistory")
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}

