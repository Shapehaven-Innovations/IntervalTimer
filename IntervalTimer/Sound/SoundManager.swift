//
//  SoundManager.swift
//  IntervalTimer
//
//  Created on 06/01/25.
//

import AVFoundation

/// Centralized audio‐player that handles AVAudioSession configuration
/// and lets any view simply call `SoundManager.shared.play(_:)`.
final class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error)")
        }
    }

    /// Play a sound with the exact asset name (NSDataAsset name or bundled file name).
    func playSound(named assetName: String) {
        guard let asset = NSDataAsset(name: assetName) else { return }
        audioPlayer = try? AVAudioPlayer(data: asset.data)
        audioPlayer?.play()
    }
}
