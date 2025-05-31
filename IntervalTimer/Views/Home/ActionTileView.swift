//
//  ActionTileView.swift
//  IntervalTimer
//  Updated 05/31/25 so that each tile’s fill & shadow adapt to Dark Mode
//

import SwiftUI

struct ActionTileView: View {
    let icon: String
    let label: String
    let bgColor: Color       // Usually from ThemeType.cardBackgrounds or accent
    let index: Int
    let action: () -> Void

    @AppStorage("enableParticles") private var enableParticles = true
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            ZStack {
                // 1) Only show particles if enabled
                if enableParticles {
                    ParticleBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // 2) Semi‑transparent overlay whose opacity depends on colorScheme
                RoundedRectangle(cornerRadius: 16)
                    .fill(bgColor.opacity(colorScheme == .dark ? 0.3 : 0.6))

                // 3) Icon + label centered
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    Text(label)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
            }
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .shadow(
                color: bgColor
                    .opacity(colorScheme == .dark ? 0.6 : 0.3),
                radius: 6,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(PressableButtonStyle())
        .animatedTile(index: index)
    }
}

struct ActionTileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActionTileView(
                icon: "play.circle.fill",
                label: "Demo",
                bgColor: .blue,
                index: 0
            ) {}
            .preferredColorScheme(.light)

            ActionTileView(
                icon: "play.circle.fill",
                label: "Demo",
                bgColor: .blue,
                index: 0
            ) {}
            .preferredColorScheme(.dark)
        }
        .environmentObject(ThemeManager.shared)
    }
}

