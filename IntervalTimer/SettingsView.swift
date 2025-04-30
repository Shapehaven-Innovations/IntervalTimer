// SettingsView.swift
// IntervalTimer
// Updated for modern iOS style with analytics & goals
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("timerDuration") private var timerDuration: Int = 60
    @AppStorage("restDuration") private var restDuration: Int = 30
    @AppStorage("sets") private var sets: Int = 1
    @AppStorage("weeklyGoal") private var weeklyGoal: Int = 3

    @State private var showingHistory = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interval Configuration").font(.headline)) {
                    Stepper(value: $timerDuration, in: 10...3600, step: 5) {
                        Text("Work: \(timerDuration) sec")
                    }
                    Stepper(value: $restDuration, in: 10...600, step: 5) {
                        Text("Rest: \(restDuration) sec")
                    }
                    Stepper(value: $sets, in: 1...20, step: 1) {
                        Text("Sets: \(sets)")
                    }
                }

                Section(header: Text("Goals").font(.headline)) {
                    Stepper(value: $weeklyGoal, in: 1...14) {
                        Text("Weekly Sessions Goal: \(weeklyGoal)")
                    }
                    Text("Complete at least \(weeklyGoal) workout sessions per week.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Accessibility & Analytics").font(.headline)) {
                    // Static indicator instead of a toggle
                    HStack {
                        Image(systemName: "figure.wave")
                            .font(.title2)
                        Text("Enhanced accessibility")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    Text("Improves readability by increasing text size and contrast.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Button(action: {
                        showingHistory = true
                    }) {
                        Label("View Session Analytics", systemImage: "chart.bar.doc.horizontal")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button(action: {
                // Reset settings to defaults
                timerDuration = 60
                restDuration = 30
                sets = 1
                weeklyGoal = 3
            }) {
                Image(systemName: "arrow.clockwise")
            })
            .sheet(isPresented: $showingHistory) {
                AnalyticsView()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

