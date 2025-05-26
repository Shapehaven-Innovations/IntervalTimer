//
//  ActionTileView.swift
//  IntervalTimer
//
//  Created by user on 5/26/25.
//


// ActionTileView.swift
import SwiftUI

struct ActionTileView: View {
    let icon: String
    let label: String
    let bgColor: Color
    let index: Int
    let action: () -> Void

    @AppStorage("enableParticles") private var enableParticles = true

    var body: some View {
        Button(action: action) {
            ZStack {
                if enableParticles {
                    ParticleBackground()
                      .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                RoundedRectangle(cornerRadius: 16)
                  .fill(bgColor.opacity(0.6))
                VStack(spacing: 8) {
                    Image(systemName: icon)
                      .font(.largeTitle)
                    Text(label)
                      .font(.headline)
                }
                .foregroundColor(.white)
            }
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .shadow(color: bgColor.opacity(0.3), radius: 6, x: 0, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
        .animatedTile(index: index)
    }
}

struct ActionTileView_Previews: PreviewProvider {
    static var previews: some View {
        ActionTileView(
            icon: "play.circle.fill",
            label: "Demo",
            bgColor: .blue,
            index: 0
        ) {}
        .environmentObject(ThemeManager.shared)
    }
}
