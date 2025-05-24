//
//  PressableButtonStyle.swift
//  IntervalTimer
//
//  Created by user on 5/24/25.
//


//
//  Styles.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.4 : 0),
                            lineWidth: 4)
                    .scaleEffect(configuration.isPressed ? 1.3 : 0.1)
                    .opacity(configuration.isPressed ? 0 : 1)
                    .animation(.easeOut(duration: 0.4),
                               value: configuration.isPressed)
            )
    }
}

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.2),
                        .white.opacity(0.6),
                        .white.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase * 350)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5)
                                .repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}

struct AnimatedTile: ViewModifier {
    let index: Int
    let animate: Bool

    func body(content: Content) -> some View {
        content
            .opacity(animate ? 1 : 0)
            .scaleEffect(animate ? 1 : 0.7)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.05),
                value: animate
            )
    }
}

extension View {
    func animatedTile(index: Int, animate: Bool) -> some View {
        modifier(AnimatedTile(index: index, animate: animate))
    }
}
