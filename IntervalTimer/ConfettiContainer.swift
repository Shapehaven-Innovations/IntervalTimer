//
//  ConfettiContainer.swift
//  IntervalTimer
//
//  Created by user on 12/31/24.
//

import SwiftUI

/// A wrapper view that measures the available space and injects it into ConfettiView
struct ConfettiContainer: View {
    var isActive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            // Force the ConfettiView to match this container's size
            ConfettiView(isActive: isActive, width: geometry.size.width)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all) // Optional if you want full screen coverage
    }
}
