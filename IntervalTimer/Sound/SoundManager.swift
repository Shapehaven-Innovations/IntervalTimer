//
//  SoundManager.swift
//  IntervalTimer
//
//  Created on 06/01/25.
//  Centralized audio‐player that configures AVAudioSession once
//  and plays any named file from the bundle root.
//

import AVFoundation
import UIKit

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
    /// First looks for “rawName.mp3” in the bundle root.
    /// If that fails, looks for “rawName.wav” in the bundle root.
    func playSound(named rawName: String) {
        // 1) Try to find .mp3 in the bundle root
        if let mp3URL = Bundle.main.url(forResource: rawName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: mp3URL)
                audioPlayer?.play()
            } catch {
                print("❌ SoundManager: failed to play \(rawName).mp3 — \(error)")
            }
            return
        }

        // 2) Otherwise try .wav
        if let wavURL = Bundle.main.url(forResource: rawName, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: wavURL)
                audioPlayer?.play()
            } catch {
                print("❌ SoundManager: failed to play \(rawName).wav — \(error)")
            }
            return
        }

        // 3) If neither found, log a warning
        print("⚠️ SoundManager: Could not find “\(rawName).mp3” or “\(rawName).wav” in main bundle.")
    }
}

