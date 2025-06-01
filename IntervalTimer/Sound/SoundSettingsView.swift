// SoundSettingsView.swift
//
//  SoundSettingsView.swift
//  IntervalTimer
//
//  Dynamic sound pickers that scan the “mySounds/” folder reference.

import SwiftUI

/// Represents a single sound file found in “mySounds/”:
///   - rawName: the filename without extension (e.g. "bell").
///   - displayName: capitalized for showing in Picker (e.g. "Bell").
struct SoundItem: Identifiable, Hashable {
    let rawName: String
    var id: String { rawName }
    var displayName: String { rawName.capitalized }
}

struct SoundSettingsView: View {
    // ————————————————————————————————————————————————————
    // 1) AppStorage keys: store the lowercase rawNames
    // ————————————————————————————————————————————————————
    @AppStorage("enableSound")      private var enableSound: Bool      = true
    @AppStorage("workSound")        private var workSoundRaw: String    = ""
    @AppStorage("restSound")        private var restSoundRaw: String    = ""
    @AppStorage("completeSound")    private var completeSoundRaw: String = ""

    // ————————————————————————————————————————————————————
    // 2) State for dynamically‑loaded sounds
    // ————————————————————————————————————————————————————
    @State private var availableSounds: [SoundItem] = []

    var body: some View {
        Section(header: Text("Sound")) {
            // — Enable/disable all sounds
            Toggle("Enable Sound", isOn: $enableSound)

            // — Work Sound Picker
            Picker("Work Sound", selection: $workSoundRaw) {
                if availableSounds.isEmpty {
                    Text("No sounds found").tag("")
                } else {
                    ForEach(availableSounds) { item in
                        Text(item.displayName).tag(item.rawName)
                    }
                }
            }

            // — Rest Sound Picker
            Picker("Rest Sound", selection: $restSoundRaw) {
                if availableSounds.isEmpty {
                    Text("No sounds found").tag("")
                } else {
                    ForEach(availableSounds) { item in
                        Text(item.displayName).tag(item.rawName)
                    }
                }
            }

            // — Complete Sound Picker
            Picker("Complete Sound", selection: $completeSoundRaw) {
                if availableSounds.isEmpty {
                    Text("No sounds found").tag("")
                } else {
                    ForEach(availableSounds) { item in
                        Text(item.displayName).tag(item.rawName)
                    }
                }
            }
        }
        .onAppear {
            loadAvailableSounds()
        }
    }

    /// Scans “mySounds/” (blue folder reference) for all .mp3 and .wav files.
    /// Builds a sorted array of SoundItem(rawName, displayName), then sets defaults if needed.
    private func loadAvailableSounds() {
        var names: Set<String> = []

        // 1) Find all .mp3 files
        if let mp3URLs = Bundle.main.urls(
            forResourcesWithExtension: "mp3",
            subdirectory: "mySounds"
        ) {
            for url in mp3URLs {
                let raw = url.deletingPathExtension().lastPathComponent
                names.insert(raw)
            }
        }

        // 2) Find all .wav files
        if let wavURLs = Bundle.main.urls(
            forResourcesWithExtension: "wav",
            subdirectory: "mySounds"
        ) {
            for url in wavURLs {
                let raw = url.deletingPathExtension().lastPathComponent
                names.insert(raw)
            }
        }

        // 3) Sort alphabetically (case‑insensitive) and convert into SoundItem array
        let sortedRawNames = Array(names).sorted { $0.lowercased() < $1.lowercased() }
        availableSounds = sortedRawNames.map { SoundItem(rawName: $0) }

        // 4) Set defaults if none stored yet
        if workSoundRaw.isEmpty, let first = availableSounds.first {
            workSoundRaw = first.rawName
        }
        if restSoundRaw.isEmpty, let first = availableSounds.first {
            restSoundRaw = first.rawName
        }
        if completeSoundRaw.isEmpty, let first = availableSounds.first {
            completeSoundRaw = first.rawName
        }
    }
}

#if DEBUG
struct SoundSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                SoundSettingsView()
            }
            .navigationTitle("Settings")
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

