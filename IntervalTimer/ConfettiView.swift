//
//  ConfettiView.swift
//
//  Created by user on [date].
//

import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    var isActive: Bool
    /// The width used to center the confetti at the top
    var width: CGFloat

    func makeUIView(context: Context) -> UIView {
        // An empty UIView to hold the confetti emitter layer
        return UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isActive {
            addConfetti(to: uiView)
        } else {
            // Remove any CAEmitterLayer if confetti is no longer active
            uiView.layer.sublayers?.removeAll { $0 is CAEmitterLayer }
        }
    }

    private func addConfetti(to view: UIView) {
        // Remove old confetti layers
        view.layer.sublayers?.removeAll { $0 is CAEmitterLayer }

        let confettiLayer = CAEmitterLayer()

        // Emit from the top center using width
        confettiLayer.emitterPosition = CGPoint(x: width / 2, y: 0)
        confettiLayer.emitterShape = .point
        confettiLayer.emitterSize = .zero

        // Configure confetti cells
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple, .orange, .cyan]
        var cells: [CAEmitterCell] = []

        for color in colors {
            let cell = CAEmitterCell()
            cell.contents = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
                .image { context in
                    color.setFill()
                    context.fill(CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
                }.cgImage

            cell.birthRate = 12
            cell.lifetime = 7.0
            cell.velocity = 150
            cell.velocityRange = 50
            
            // Emit downward, but fan out more widely (±90° around downward).
            cell.emissionLongitude = .pi / 2  // downward
            cell.emissionRange = .pi / 2     // wide spread horizontally

            cell.spin = 3.5
            cell.spinRange = 1.0
            cell.scale = 0.08
            cell.scaleRange = 0.04

            cells.append(cell)
        }

        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)

        // Stop emitting after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            confettiLayer.birthRate = 0
        }
    }
}
