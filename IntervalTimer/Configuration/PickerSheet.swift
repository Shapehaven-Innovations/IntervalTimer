///
//  PickerSheet.swift
//  IntervalTimer
//  Modernized duration picker in minutes & seconds
//  Updated 05/28/25
//

import SwiftUI

/// A modal sheet that lets the user pick a duration in minutes + seconds.
struct PickerSheet: View {
    let type: PickerType
    @Binding var value: Int

    @Environment(\.presentationMode) private var dismiss
    @EnvironmentObject    private var themeManager: ThemeManager

    private let maxSeconds = 300
    private var maxMinutes: Int { maxSeconds / 60 }

    @State private var minutes: Int
    @State private var seconds: Int

    private var themeColor: Color {
        switch type {
        case .getReady: return themeManager.selected.cardBackgrounds[0]
        case .rounds:   return themeManager.selected.cardBackgrounds[1]
        case .work:     return themeManager.selected.cardBackgrounds[2]
        case .rest:     return themeManager.selected.cardBackgrounds[3]
        }
    }

    init(type: PickerType, value: Binding<Int>) {
        self.type = type
        self._value = value
        let total = min(max(value.wrappedValue, 1), maxSeconds)
        _minutes = State(initialValue: total / 60)
        _seconds = State(initialValue: total % 60)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Overall light background + subtle tint
                Color(.systemBackground)
                    .ignoresSafeArea()
                themeColor.opacity(0.05)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // ——— Engaging Title ———
                    Text(type.title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(themeColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(themeColor.opacity(0.2))
                        .clipShape(Capsule())
                        .shadow(color: themeColor.opacity(0.3), radius: 6, x: 0, y: 4)
                        .padding(.top)

                    // ——— Picker Card ———
                    HStack(spacing: 0) {
                        // Minutes
                        Picker("Minutes", selection: $minutes) {
                            ForEach(0...maxMinutes, id: \.self) { m in
                                Text("\(m) min").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        // Seconds
                        Picker("Seconds", selection: $seconds) {
                            ForEach(0..<60, id: \.self) { s in
                                Text(String(format: "%02d sec", s)).tag(s)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    .onChange(of: minutes) { syncValue() }
                    .onChange(of: seconds) { syncValue() }

                    // ——— Live Preview ———
                    Text("Selected: \(minutes) m \(String(format: "%02d", seconds)) s")
                        .font(.headline)
                        .foregroundColor(themeColor)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.bottom, 40)
            }
            // Hide default nav‐title but keep Cancel/Done
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Color.clear.frame(height: 0) // suppress center title
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        syncValue()
                        dismiss.wrappedValue.dismiss()
                    }
                }
            }
        }
        // Force light mode for crisp wheels
        .environment(\.colorScheme, .light)
    }

    private func syncValue() {
        let total = minutes * 60 + seconds
        value = min(max(total, 1), maxSeconds)
    }
}

#if DEBUG
struct PickerSheet_Previews: PreviewProvider {
    @State static var tmp = 90
    static var previews: some View {
        PickerSheet(type: .work, value: $tmp)
            .environmentObject(ThemeManager.shared)
    }
}
#endif

