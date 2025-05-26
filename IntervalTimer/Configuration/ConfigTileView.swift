// ConfigTileView.swift
// IntervalTimer
// Updated 05/26/25 to render particles behind each tile

import SwiftUI

struct ConfigTileView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color       // from ThemeType.cardBackgrounds
    let action: () -> Void

    @State private var wobble = false
    @State private var shrink = false

    /// Honor the user’s preference for particles
    @AppStorage("enableParticles") private var enableParticles: Bool = true

    var body: some View {
        Button(action: action) {
            ZStack {
                // 1) Per‑tile particle background
                if enableParticles {
                    ParticleBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                // 2) Semi‑opaque overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.6))
                // 3) Icon + labels
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .rotationEffect(icon == "bed.double.fill"
                                        ? Angle(degrees: wobble ? 10 : -10)
                                        : .zero)
                        .scaleEffect(icon == "bolt.fill"
                                     ? (shrink ? 0.8 : 1.0)
                                     : 1.0)
                        .onAppear {
                            if icon == "bed.double.fill" {
                                withAnimation(.easeInOut(duration: 0.4)
                                                .repeatForever(autoreverses: true)) {
                                    wobble.toggle()
                                }
                            }
                            if icon == "bolt.fill" {
                                withAnimation(.easeInOut(duration: 0.6)
                                                .repeatForever(autoreverses: true)) {
                                    shrink.toggle()
                                }
                            }
                        }
                    Text(label)
                        .font(.headline)
                    Text(value)
                        .font(.subheadline).bold()
                }
                .foregroundColor(.white)
                .padding()
            }
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#if DEBUG
struct ConfigTileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ConfigTileView(icon: "bolt.fill", label: "Get Ready", value: "00:03", color: .red) {}
            ConfigTileView(icon: "repeat.circle.fill", label: "Rounds", value: "8", color: .blue) {}
        }
        .padding()
        .environmentObject(ThemeManager.shared)
    }
}
#endif

