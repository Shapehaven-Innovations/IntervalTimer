//
//  SoundSettingsView.swift
//  IntervalTimer
//
//  Created by You on 2025‑06‑01.
//  Allows the user to toggle sound on/off and pick which SoundType
//  to use for Work, Rest, and Complete phases.
//  Uses lowercase `fileName` as each Picker’s tag.
//

import SwiftUI

struct SoundSettingsView: View {
    // ────────────────────────────────────────────────────────────
    // 1) AppStorage keys (we store the lowercase fileName, not rawValue)
    // ────────────────────────────────────────────────────────────
    @AppStorage("enableSound")   private var enableSound: Bool   = true
    @AppStorage("workSound")     private var workSoundFile: String = SoundType.beep.fileName
    @AppStorage("restSound")     private var restSoundFile: String = SoundType.beep.fileName
    @AppStorage("completeSound") private var completeSoundFile: String = SoundType.beep.fileName

    // ────────────────────────────────────────────────────────────
    // 2) Body: one Section (to embed inside your existing Form)
    // ────────────────────────────────────────────────────────────
    var body: some View {
        Section(header: Text("Sound")) {
            // Toggle ON/OFF
            Toggle("Enable Sound", isOn: $enableSound)

            // Work Sound Picker
            Picker("Work Sound", selection: $workSoundFile) {
                ForEach(SoundType.allCases) { sound in
                    // Use text = sound.rawValue ("Beep","Chime","Bell"),
                    // but tag = sound.fileName ("beep","chime","bell").
                    Text(sound.rawValue).tag(sound.fileName)
                }
            }
            .disabled(!enableSound)

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
        Form {
            SoundSettingsView()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

