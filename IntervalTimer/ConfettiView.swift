//
//  ConfettiView.swift
//  IntervalTimer
//
//  Created by user on 12/30/24.
//
import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    var isActive: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if isActive {
            addConfetti(to: view)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isActive {
            addConfetti(to: uiView)
        } else {
            uiView.layer.sublayers?.removeAll { $0 is CAEmitterLayer }
        }
    }

    private func addConfetti(to view: UIView) {
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 10)
        confettiLayer.emitterShape = .line
        
        // Configure Confetti Colors and Cells
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple, .orange, .cyan]
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.contents = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { context in
                color.setFill()
                context.fill(CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
            }.cgImage
            cell.birthRate = 12
            cell.lifetime = 7.0
            cell.velocity = 150
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3.5
            cell.spinRange = 1.0
            cell.scale = 0.08
            cell.scaleRange = 0.04
            cells.append(cell)
        }
        
        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        
        // Stop emitting confetti after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            confettiLayer.birthRate = 0
        }
    }
}
