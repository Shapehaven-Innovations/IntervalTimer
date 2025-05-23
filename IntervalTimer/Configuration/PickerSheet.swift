//
//  PickerSheet.swift
//  IntervalTimer
//
//  Extracted from ContentView on May 23 2025.
//  A reusable stepped-value sheet for Get-Ready, Rounds, Work, and Rest.
//

import SwiftUI

/// A modal sheet that lets the user adjust one `Int`-based workout parameter.
struct PickerSheet: View {
    let type: ContentView.PickerType          // which value we’re editing
    @Binding var value: Int                   // two-way binding to that value

    @Environment(\.presentationMode) private var dismiss

    /// Accent colour pulled from the Theme for visual context.
    private var themeColor: Color {
        switch type {
        case .getReady: return Theme.cardBackgrounds[0]
        case .rounds:   return Theme.cardBackgrounds[1]
        case .work:     return Theme.cardBackgrounds[2]
        case .rest:     return Theme.cardBackgrounds[3]
        }
    }

    /// Central range for all pickers—easy to tweak later.
    private let range = 1...300

    var body: some View {
        NavigationView {
            ZStack {
                themeColor.opacity(0.1).ignoresSafeArea()

                Form {
                    Section {
                        Stepper(value: $value, in: range) {
                            Text("\(value) seconds")
                                .accessibilityLabel("\(type.title) seconds")
                        }
                    } header: {
                        Text(type.title)
                            .font(.headline)
                            .foregroundColor(themeColor)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss.wrappedValue.dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PickerSheet_Previews: PreviewProvider {
    @State static var temp = 45
    static var previews: some View {
        PickerSheet(type: .work, value: $temp)
            .preferredColorScheme(.dark)
    }
}
#endif
