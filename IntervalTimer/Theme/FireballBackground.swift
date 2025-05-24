//
//  FireballBackground.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//

import SwiftUI

struct Fireball: Identifiable {
    let id = UUID()
    let x: CGFloat
    let size: CGFloat
    let speed: Double
}

private struct FireballView: View {
    let fb: Fireball
    let geoSize: CGSize
    let onComplete: () -> Void

    @State private var animate = false

    var body: some View {
        Image(systemName: "flame.fill")
            .font(.system(size: fb.size))
            .foregroundColor(.orange)
            .shadow(color: .red, radius: fb.size * 0.3)
            .rotationEffect(.degrees(animate ? 360 : 0))
            .offset(
                x: (fb.x - 0.5) * geoSize.width,
                y: animate
                    ? -geoSize.height / 2 - fb.size
                    : geoSize.height / 2 + fb.size
            )
            .onAppear {
                withAnimation(.linear(duration: fb.speed)) {
                    animate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + fb.speed) {
                    onComplete()
                }
            }
    }
}

private struct AnimatedGradientBackground: View {
    @State private var animate = false

    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.purple.opacity(0.6),
                Color.blue.opacity(0.4),
                Color.black
            ]),
            center: .center,
            startRadius: animate ? 50 : 150,
            endRadius: animate ? 500 : 300
        )
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true),
                   value: animate)
        .onAppear { animate = true }
    }
}

struct FireballBackground: View {
    @State private var fireballs: [Fireball] = []
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AnimatedGradientBackground()
                ForEach(fireballs) { fb in
                    FireballView(fb: fb, geoSize: geo.size) {
                        fireballs.removeAll { $0.id == fb.id }
                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                fireballs.append(
                    Fireball(
                        x:    .random(in: 0...1),
                        size: .random(in: 30...70),
                        speed: .random(in: 4...7)
                    )
                )
            }
        }
    }
}

