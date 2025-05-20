// OnboardingView.swift
// IntervalTimer
// Animated fireball onboarding, collects sex, height, weight

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @AppStorage("userSex")     private var userSex:     String = ""
    @AppStorage("userHeight")  private var userHeight:  Int    = 170
    @AppStorage("userWeight")  private var userWeight:  Int    = 70

    @State private var selectedSex: String = "Male"
    @State private var height:      Int    = 170
    @State private var weight:      Int    = 70

    var body: some View {
        ZStack {
            FireballBackground()
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                Text("Let's get to know you")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))

                Form {
                    Section(header: Text("Sex")) {
                        Picker("Sex", selection: $selectedSex) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section(header: Text("Height (cm)")) {
                        Stepper("\(height) cm", value: $height, in: 100...250)
                    }

                    Section(header: Text("Weight (kg)")) {
                        Stepper("\(weight) kg", value: $weight, in: 30...200)
                    }
                }
                .frame(maxHeight: 300)
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(12)
                .padding(.horizontal)

                Button(action: finishOnboarding) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
            }
            .padding(.top, 60)
        }
    }

    private func finishOnboarding() {
        userSex    = selectedSex
        userHeight = height
        userWeight = weight
        hasOnboarded = true
    }
}

struct FireballBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black, .purple]),
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0..<5) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.orange, Color.red]),
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
