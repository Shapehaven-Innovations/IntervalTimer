// GoalsView.swift
// IntervalTimer
// Set daily/weekly/monthly goals + free‑form notes

import SwiftUI

struct GoalsView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage("dailyGoal")   private var dailyGoal:   Int = 1
    @AppStorage("weeklyGoal")  private var weeklyGoal:  Int = 7
    @AppStorage("monthlyGoal") private var monthlyGoal: Int = 30
    @AppStorage("goalNotes")   private var goalNotes:   String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goals")) {
                    Stepper("Daily: \(dailyGoal)",
                            value: $dailyGoal,
                            in: 1...24)
                    Stepper("Weekly: \(weeklyGoal)",
                            value: $weeklyGoal,
                            in: 1...168)
                    Stepper("Monthly: \(monthlyGoal)",
                            value: $monthlyGoal,
                            in: 1...744)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $goalNotes)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Goals")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
