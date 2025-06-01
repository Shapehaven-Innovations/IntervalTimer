// SoundManager.swift
//
//  SoundManager.swift
//  IntervalTimer
//
//  Created on 06/01/25.
//

import AVFoundation
import UIKit

/// Centralized audio‑player that configures AVAudioSession once
/// and plays any named file (searching in the “mySounds” folder).
final class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    /// Configure AVAudioSession for playback (mixable with other audio).
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Audio session setup failed: \(error)")
        }
    }

    /// Attempt to play a sound whose filename (no extension) is `rawName`.
    /// Searches for “rawName.mp3” first, then “rawName.wav” inside “mySounds/”.
    func playSound(named rawName: String) {
        guard !rawName.isEmpty else { return }

        // 1) Look for .mp3 inside “mySounds/”
        if let mp3URL = Bundle.main.url(
            forResource: rawName,
            withExtension: "mp3",
            subdirectory: "mySounds"
        ) {
            audioPlayer = try? AVAudioPlayer(contentsOf: mp3URL)
            audioPlayer?.play()
            return
        }

        // 2) Otherwise look for .wav
        if let wavURL = Bundle.main.url(
            forResource: rawName,
            withExtension: "wav",
            subdirectory: "mySounds"
        ) {
            audioPlayer = try? AVAudioPlayer(contentsOf: wavURL)
            audioPlayer?.play()
            return
        }

        // 3) If neither is found, no‑op
        print("⚠️ SoundManager: Could not find “\(rawName).mp3” or “\(rawName).wav” in mySounds/")
    }
}

