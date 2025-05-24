///
//  ConfigTileView.swift
//  IntervalTimer
//
//  Created by You on 5/24/25.
//

import SwiftUI

struct ConfigTileView: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let action: () -> Void

    @State private var wobble = false
    @State private var shrink = false

    var body: some View {
        Button(action: action) {
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

                Text(label).font(.headline)
                Text(value).font(.subheadline).bold()
            }
            .foregroundColor(.white)
            .frame(minHeight: 140)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

