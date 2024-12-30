// SettingsView.swift
// IntervalTimer
//
// Created by user on 12/17/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var timerDuration: Int
    @Binding var restDuration: Int
    @Binding var sets: Int

    var body: some View {
        VStack {
            Text("Interval Configuration Settings")
                .font(.largeTitle)
                .padding()

            Stepper(value: $timerDuration, in: 10...3600, step: 5) {
                Text("Work Duration: \(timerDuration) seconds")
                    .font(.title2)
            }
            .padding()

            Stepper(value: $restDuration, in: 10...600, step: 5) {
                Text("Rest Duration: \(restDuration) seconds")
                    .font(.title2)
            }
            .padding()

            Stepper(value: $sets, in: 1...20, step: 1) {
                Text("Sets: \(sets)")
                    .font(.title2)
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}
