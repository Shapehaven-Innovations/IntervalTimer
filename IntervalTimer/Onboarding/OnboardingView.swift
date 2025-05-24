//
//  OnboardingView.swift
//  IntervalTimer
//
//  Created by user on 5/??/25.
//

import SwiftUI

private var name: String { UIDevice.current.name }

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool   = false
    @AppStorage("userSex")      private var userSex:     String = ""
    @AppStorage("userHeight")   private var userHeight:  Int    = 170
    @AppStorage("userWeight")   private var userWeight:  Int    = 70
    @AppStorage("weightUnit")   private var weightUnit:  String = "kg"

    // UI State
    @State private var selectedSex:  String = "Male"
    @State private var heightFeet:   Int    = 5
    @State private var heightInches: Int    = 7
    @State private var heightCm:     Int    = 170
    @State private var selectedUnit: String = "kg"
    @State private var weightText:   String = "70"

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            FireballBackground().ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Welcome \(name)!")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Let’s get started.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                Form {
                    Section(header:
                        Text("SEX")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.6))
                    ) {
                        Picker("", selection: $selectedSex) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(.segmented)
                    }

                    Section(header:
                        Text("HEIGHT")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.6))
                    ) {
                        Stepper("Feet: \(heightFeet)′",   value: $heightFeet, in: 3...7)
                        Stepper("Inches: \(heightInches)″", value: $heightInches, in: 0...11)
                        HStack {
                            Text("≈ \(heightCm) cm")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .onChange(of: heightFeet)   { _ in updateCm() }
                    .onChange(of: heightInches) { _ in updateCm() }

                    Section(header:
                        Text("UNITS")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.3))
                    ) {
                        Picker("", selection: $selectedUnit) {
                            Text("kg").tag("kg")
                            Text("lbs").tag("lbs")
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedUnit) { old, new in
                            convertWeight(from: old, to: new)
                        }
                    }

                    Section(header:
                        Text("WEIGHT (\(selectedUnit.uppercased()))")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.3))
                    ) {
                        TextField("Enter weight", text: $weightText)
                            .keyboardType(.numberPad)
                            .onChange(of: weightText) { _, new in
                                weightText = new.filter(\.isNumber)
                            }
                    }

                    Section(footer:
                        Text("Your data is not shared — we stand for data privacy.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    ) {
                        EmptyView()
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .padding(.horizontal)
                .listStyle(InsetGroupedListStyle())
                .frame(maxHeight: 460)

                Button(action: finishOnboarding) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
            }
            .padding(.top, 60)
            .onAppear(perform: syncFromStorage)
        }
    }

    // Helpers…

    private func updateCm() {
        let totalInches = heightFeet * 12 + heightInches
        heightCm = Int(round(Double(totalInches) * 2.54))
    }

    private func convertWeight(from old: String, to new: String) {
        guard let v = Int(weightText) else { return }
        let converted = (new == "lbs")
            ? Double(v) * 2.20462
            : Double(v) / 2.20462
        weightText = String(Int(round(converted)))
    }

    private func syncFromStorage() {
        selectedSex  = userSex.isEmpty ? "Male" : userSex
        let inches    = Int(round(Double(userHeight) / 2.54))
        heightFeet   = inches / 12
        heightInches = inches % 12
        heightCm     = userHeight
        selectedUnit = weightUnit
        weightText   = String(userWeight)
    }

    private func finishOnboarding() {
        userSex      = selectedSex
        userHeight   = heightCm
        userWeight   = Int(weightText) ?? userWeight
        weightUnit   = selectedUnit
        withAnimation { hasOnboarded = true }
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif

