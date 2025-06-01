//
//  SoundSettingsView.swift
//  IntervalTimer
//
//  Created on 06/01/25.
//

import SwiftUI

struct SoundSettingsView: View {
    @AppStorage("enableSound") private var enableSound: Bool = true
    @AppStorage("workSound")   private var workSound: String = SoundType.beep.rawValue
    @AppStorage("restSound")   private var restSound: String = SoundType.beep.rawValue
    @AppStorage("completeSound")
    private var completeSound: String = SoundType.beep.rawValue

    private let soundTypes = SoundType.allCases

    var body: some View {
        Section(header: Text("Sound")) {
            Toggle("Enable Sound", isOn: $enableSound)

            Picker("Work Sound", selection: $workSound) {
                ForEach(soundTypes) { type in
                    Text(type.rawValue).tag(type.rawValue)
                }
            }

            Picker("Rest Sound", selection: $restSound) {
                ForEach(soundTypes) { type in
                    Text(type.rawValue).tag(type.rawValue)
                }
            }

            Picker("Complete Sound", selection: $completeSound) {
                ForEach(soundTypes) { type in
                    Text(type.rawValue).tag(type.rawValue)
                }
            }
        }
    }
}

#if DEBUG
struct SoundSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SoundSettingsView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
