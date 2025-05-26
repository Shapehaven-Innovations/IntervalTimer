//
//  ConfigTilesView.swift
//  IntervalTimer
//
//  Created by user on 5/26/25.
//


// ConfigTilesView.swift
import SwiftUI

struct ConfigTilesView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // mirror exactly what ContentView had
    @AppStorage("getReadyDuration") private var getReadyDuration = 3
    @AppStorage("timerDuration")    private var timerDuration    = 20
    @AppStorage("restDuration")     private var restDuration     = 10
    @AppStorage("sets")             private var sets             = 8
    @AppStorage("lastWorkoutName")  private var lastWorkoutName  = ""

    @State private var activePicker: PickerType?

    private func binding(for type: PickerType) -> Binding<Int> {
        switch type {
        case .getReady:
            return Binding(
                get: { getReadyDuration },
                set: { getReadyDuration = $0; lastWorkoutName = "" }
            )
        case .rounds:
            return Binding(
                get: { sets },
                set: { sets = $0; lastWorkoutName = "" }
            )
        case .work:
            return Binding(
                get: { timerDuration },
                set: { timerDuration = $0; lastWorkoutName = "" }
            )
        case .rest:
            return Binding(
                get: { restDuration },
                set: { restDuration = $0; lastWorkoutName = "" }
            )
        }
    }

    var body: some View {
        Group {
            ConfigTileView(
                icon:  "bolt.fill",
                label: "Get Ready",
                value: format(getReadyDuration),
                color: themeManager.selected.cardBackgrounds[0]
            ) { activePicker = .getReady }

            ConfigTileView(
                icon:  "repeat.circle.fill",
                label: "Rounds",
                value: "\(sets)",
                color: themeManager.selected.cardBackgrounds[1]
            ) { activePicker = .rounds }

            ConfigTileView(
                icon:  "flame.fill",
                label: "Work",
                value: format(timerDuration),
                color: themeManager.selected.cardBackgrounds[2]
            ) { activePicker = .work }

            ConfigTileView(
                icon:  "bed.double.fill",
                label: "Rest",
                value: format(restDuration),
                color: themeManager.selected.cardBackgrounds[3]
            ) { activePicker = .rest }
        }
        .sheet(item: $activePicker) { picker in
            PickerSheet(type: picker, value: binding(for: picker))
        }
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

struct ConfigTilesView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigTilesView()
          .environmentObject(ThemeManager.shared)
    }
}
