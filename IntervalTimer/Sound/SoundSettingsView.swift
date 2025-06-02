//
//  SoundItem.swift
//  IntervalTimer
//
//  Created by user on 6/1/25.
//


//
//  SoundSettingsView.swift
//  IntervalTimer
//
//  Created by You on 2025‑06‑01.
//  Refactored to use FileManager fallback if Bundle lookup fails.
//

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
    // ————————————————
    // AppStorage keys
    // ————————————————
    @AppStorage("enableSound")   private var enableSound: Bool      = true
    @AppStorage("workSound")     private var workSoundRaw: String    = ""
    @AppStorage("restSound")     private var restSoundRaw: String    = ""
    @AppStorage("completeSound") private var completeSoundRaw: String = ""

    // ————————————————
    // Local state for dynamically‐loaded sounds
    // ————————————————
    @State private var availableSounds: [SoundItem] = []
    @State private var isLoadingSounds = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sound")) {
                    // Toggle on/off all sounds
                    Toggle("Enable Sound", isOn: $enableSound)

                    // While scanning, show a “Loading…” row
                    if isLoadingSounds {
                        HStack {
                            Text("Loading sounds…")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    // If scan finished and no files were found:
                    else if availableSounds.isEmpty {
                        HStack {
                            Text("No sounds found")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    // Otherwise, show the three pickers
                    else {
                        // — Work Sound Picker
                        Picker("Work Sound", selection: $workSoundRaw) {
                            ForEach(availableSounds) { item in
                                Text(item.displayName).tag(item.rawName)
                            }
                        }

                        // — Rest Sound Picker
                        Picker("Rest Sound", selection: $restSoundRaw) {
                            ForEach(availableSounds) { item in
                                Text(item.displayName).tag(item.rawName)
                            }
                        }

                        // — Complete Sound Picker
                        Picker("Complete Sound", selection: $completeSoundRaw) {
                            ForEach(availableSounds) { item in
                                Text(item.displayName).tag(item.rawName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear(perform: loadAvailableSounds)
        }
    }

    /// Scans “mySounds/” for all .mp3 and .wav files.  
    /// 1) First attempts Bundle lookups;  
    /// 2) If nothing is found, falls back to FileManager enumeration.  
    /// 3) Populates `availableSounds` and defaults each AppStorage if still empty.
    private func loadAvailableSounds() {
        // Only run once per view‐appearance
        guard isLoadingSounds else { return }

        var names: Set<String> = []

        // ——————————————
        // 1) Bundle API approach
        // ——————————————
        // Look for .mp3 under “mySounds/”
        if let mp3URLs = Bundle.main.urls(
            forResourcesWithExtension: "mp3",
            subdirectory: "mySounds"
        ) {
            print("🔍 [Bundle‑API] mp3URLs.count = \(mp3URLs.count)")
            for url in mp3URLs {
                let raw = url.deletingPathExtension().lastPathComponent
                names.insert(raw)
                print("🔍 [Bundle‑API] Found mp3: \(url.lastPathComponent)")
            }
        } else {
            print("⚠️ [Bundle‑API] mp3URLs is nil")
        }

        // Look for .wav under “mySounds/”
        if let wavURLs = Bundle.main.urls(
            forResourcesWithExtension: "wav",
            subdirectory: "mySounds"
        ) {
            print("🔍 [Bundle‑API] wavURLs.count = \(wavURLs.count)")
            for url in wavURLs {
                let raw = url.deletingPathExtension().lastPathComponent
                names.insert(raw)
                print("🔍 [Bundle‑API] Found wav: \(url.lastPathComponent)")
            }
        } else {
            print("⚠️ [Bundle‑API] wavURLs is nil")
        }

        // ——————————————
        // 2) FileManager fallback if Bundle found nothing
        // ——————————————
        if names.isEmpty {
            print("🔸 [FileManager] Bundle approach found zero files. Trying FileManager…")
            if let resourceURL = Bundle.main.resourceURL {
                let folderURL = resourceURL.appendingPathComponent("mySounds")
                do {
                    let contents = try FileManager.default.contentsOfDirectory(
                        at: folderURL,
                        includingPropertiesForKeys: nil,
                        options: [.skipsHiddenFiles]
                    )
                    for url in contents {
                        let ext = url.pathExtension.lowercased()
                        guard ext == "mp3" || ext == "wav" else { continue }
                        let raw = url.deletingPathExtension().lastPathComponent
                        names.insert(raw)
                        print("🔸 [FileManager] Found \(url.lastPathComponent)")
                    }
                } catch {
                    print("⚠️ [FileManager] Error enumerating mySounds/: \(error)")
                }
            } else {
                print("⚠️ [FileManager] Bundle.main.resourceURL was nil.")
            }
        }

        // ——————————————
        // 3) Sort & build SoundItem array
        // ——————————————
        let sortedRawNames = Array(names).sorted { $0.lowercased() < $1.lowercased() }
        availableSounds = sortedRawNames.map { SoundItem(rawName: $0) }

        // 4) Default each AppStorage key to the first sound if still empty
        if let first = availableSounds.first {
            if workSoundRaw.isEmpty {
                workSoundRaw = first.rawName
                print("ℹ️ [Defaults] Defaulting workSoundRaw → \(first.rawName)")
            }
            if restSoundRaw.isEmpty {
                restSoundRaw = first.rawName
                print("ℹ️ [Defaults] Defaulting restSoundRaw → \(first.rawName)")
            }
            if completeSoundRaw.isEmpty {
                completeSoundRaw = first.rawName
                print("ℹ️ [Defaults] Defaulting completeSoundRaw → \(first.rawName)")
            }
        } else {
            print("⚠️ [Final] No sound files found in mySounds/")
        }

        // Mark loading as finished so UI updates
        isLoadingSounds = false
    }
}

#if DEBUG
struct SoundSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SoundSettingsView()
    }
}
#endif
