//
//  SoundSettingsView.swift
//  IntervalTimer
//
//  Created by You on 2025‑06‑01.


import SwiftUI

struct SoundSettingsView: View {
    // ────────────────────────────────────────────────────────────
    // 1) AppStorage keys (we store the lowercase fileName, not rawValue)
    // ────────────────────────────────────────────────────────────
    @AppStorage("enableSound")   private var enableSound: Bool    = true
    @AppStorage("workSound")     private var workSoundFile: String    = SoundType.beep.fileName
    @AppStorage("restSound")     private var restSoundFile: String    = SoundType.beep.fileName
    @AppStorage("completeSound") private var completeSoundFile: String = SoundType.beep.fileName

    var body: some View {
        // ── 1) Section: Sound Enablement ─────────────────────────
        Section(header: Text("Sound Enablement")) {
            Toggle("Enable Sound", isOn: $enableSound)
        }

        // ── 2) Section: Sound Effects ────────────────────────────
        Section(header: Text("Sound Effects")) {
            // Work Sound Picker
            Picker("Work Sound", selection: $workSoundFile) {
                ForEach(SoundType.allCases) { sound in
                    Text(sound.rawValue)      // e.g. “Beep”, “Chime”, “Bell”
                        .tag(sound.fileName)  // e.g. “beep”, “chime”, “bell”
                }
            }
            .disabled(!enableSound) // disable if sound is off

            // Rest Sound Picker
            Picker("Rest Sound", selection: $restSoundFile) {
                ForEach(SoundType.allCases) { sound in
                    Text(sound.rawValue).tag(sound.fileName)
                }
            }
            .disabled(!enableSound)

            // Complete Sound Picker
            Picker("Complete Sound", selection: $completeSoundFile) {
                ForEach(SoundType.allCases) { sound in
                    Text(sound.rawValue).tag(sound.fileName)
                }
            }
            .disabled(!enableSound)
        }
    }
}

#if DEBUG
struct SoundSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            Form {
                SoundSettingsView()
            }
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")

            // Dark Mode Preview
            Form {
                SoundSettingsView()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
#endif

