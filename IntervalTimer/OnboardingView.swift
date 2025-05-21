// OnboardingView.swift
// IntervalTimer
// Animated colorful “fireballs” onboarding, collects sex, height (ft/in & cm), weight + privacy footer

import SwiftUI

// MARK: – User Identity
private var name: String { UIDevice.current.name }

struct OnboardingView: View {
    // MARK: – Stored
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool   = false
    @AppStorage("userSex")      private var userSex:     String = ""
    @AppStorage("userHeight")   private var userHeight:  Int    = 170
    @AppStorage("userWeight")   private var userWeight:  Int    = 70
    @AppStorage("weightUnit")   private var weightUnit:  String = "kg"

    // MARK: – UI State
    @State private var selectedSex:  String = "Male"
    @State private var heightFeet:   Int    = 5
    @State private var heightInches: Int    = 7
    @State private var heightCm:     Int    = 170
    @State private var selectedUnit: String = "kg"
    @State private var weightText:   String = "70"

    var body: some View {
        ZStack {
            // White canvas
            Color.white.ignoresSafeArea()
            // Animated colored “fireballs”
            FireballBackground().ignoresSafeArea()

            VStack(spacing: 24) {
                // Title
                VStack(spacing: 4) {
                    Text("Welcome \(name)!")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Let’s get started.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                Form {
                    // SEX (darker)
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

                    // HEIGHT (darker)
                    Section(header:
                        Text("HEIGHT")
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.6))
                    ) {
                        Stepper("Feet: \(heightFeet)′", value: $heightFeet, in: 3...7)
                        Stepper("Inches: \(heightInches)″", value: $heightInches, in: 0...11)
                        HStack {
                            Text("≈ \(heightCm) cm")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    // iOS‑17 style onChange
                    .onChange(of: heightFeet) { updateCm() }
                    .onChange(of: heightInches) { updateCm() }

                    // UNITS
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
                        .onChange(of: selectedUnit) { oldUnit, newUnit in
                            convertWeight(from: oldUnit, to: newUnit)
                        }
                    }

                    // WEIGHT
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

                    // PRIVACY FOOTER
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

    // MARK: – Helpers

    private func updateCm() {
        let totalInches = heightFeet * 12 + heightInches
        heightCm = Int(round(Double(totalInches) * 2.54))
    }

    private func convertWeight(from old: String, to new: String) {
        guard let value = Int(weightText) else { return }
        let converted = (new == "lbs")
            ? Double(value) * 2.20462
            : Double(value) / 2.20462
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
        hasOnboarded = true
    }
}

// MARK: – Fireball Background

private struct FireballBackground: View {
    @State private var animate = false
    private let themeColors: [Color] = [
        .yellow, .teal, .green, .red,
        .orange, .blue, .purple, .pink
    ]

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { idx in
                let color = themeColors[idx]
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [color.opacity(0.6), color.opacity(0.2)]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .offset(
                        x: animate
                            ? CGFloat.random(in: -200...200)
                            : CGFloat.random(in: -200...200),
                        y: animate
                            ? CGFloat.random(in: -600...0)
                            : CGFloat.random(in: -600...0)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

