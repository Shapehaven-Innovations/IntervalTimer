// ParticleBackground.swift
// IntervalTimer
// Dynamic, theme‑aware gradient + subtle particle effect
//
// Renamed from FireballBackground.swift on 05/26/25

import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let size: CGFloat
    let speed: Double
    let color: Color
}

private struct ParticleView: View {
    let particle: Particle
    let geoSize: CGSize
    let onComplete: () -> Void
    @State private var animate = false

    var body: some View {
        Circle()
            .fill(particle.color.opacity(0.7))
            .frame(width: particle.size, height: particle.size)
            .offset(
                x: (particle.x - 0.5) * geoSize.width,
                y: animate
                    ? -geoSize.height/2 - particle.size
                    : geoSize.height/2 + particle.size
            )
            .onAppear {
                withAnimation(.linear(duration: particle.speed)) {
                    animate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + particle.speed) {
                    onComplete()
                }
            }
    }
}

private struct DynamicGradientBackground: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var animate = false

    var body: some View {
        let colors = themeManager.selected.cardBackgrounds
        RadialGradient(
            gradient: Gradient(colors: [
                colors.randomElement() ?? .black,
                colors.randomElement() ?? .black,
                themeManager.selected.backgroundColor
            ]),
            center: .center,
            startRadius: animate ? 50 : 200,
            endRadius: animate ? 400 : 600
        )
        .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true),
                   value: animate)
        .onAppear { animate = true }
    }
}

struct ParticleBackground: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var particles: [Particle] = []
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                DynamicGradientBackground()
                ForEach(particles) { p in
                    ParticleView(particle: p, geoSize: geo.size) {
                        particles.removeAll { $0.id == p.id }
                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                let palette = themeManager.selected.cardBackgrounds
                particles.append(.init(
                    x: CGFloat.random(in: 0...1),
                    size: CGFloat.random(in: 20...60),
                    speed: Double.random(in: 4...8),
                    color: palette.randomElement() ?? .white
                ))
            }
        }
    }
}

