//
//  AnimatedTile.swift
//  IntervalTimer
//
//  Created by user on 5/26/25.
//


import SwiftUI

/// Applies the same “bring in with a spring + staggered delay” animation
/// that was in your `ContentView` helper modifier.
struct AnimatedTile: ViewModifier {
    let index: Int
    let animate = true

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
    func animatedTile(index: Int) -> some View {
        modifier(AnimatedTile(index: index))
    }
}
