// SettingsView.swift
// IntervalTimer
// Interactive Settings UI: App Theme, Screen Background & Particles toggle

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager

    @AppStorage("screenBackground") private var backgroundRaw: String = BackgroundOption.white.rawValue
    @AppStorage("enableParticles")  private var enableParticles: Bool = true

    private let backgrounds = BackgroundOption.allCases

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Title
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Settings")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // Particles Toggle Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Particles")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Toggle(isOn: $enableParticles) {
                        Text("Enable Particles Behind Tiles")
                            .foregroundColor(.primary)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: themeManager.selected.accent))
                }
                .padding(.horizontal, 20)

                // App Theme Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("App Theme")
                        .font(.headline)
                        .foregroundColor(.primary)

                    // Current theme name
                    Text(themeManager.selected.rawValue)
                        .font(.subheadline)
                        .foregroundColor(themeManager.selected.accent)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(themeManager.selected.accent, lineWidth: 2)
                        )

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 80), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(ThemeType.allCases) { theme in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.accent)
                                .frame(width: 80, height: 80)
                                .scaleEffect(theme == themeManager.selected ? 1.1 : 1.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(theme.accent,
                                                lineWidth: theme == themeManager.selected ? 8 : 0)
                                )
                                .shadow(
                                    color: theme.accent.opacity(theme == themeManager.selected ? 0.6 : 0),
                                    radius: theme == themeManager.selected ? 15 : 0
                                )
                                .animation(.easeInOut(duration: 0.2), value: themeManager.selected)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        themeManager.selected = theme
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Screen Background Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Screen Background")
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 24) {
                        ForEach(backgrounds) { bg in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(bg.color)
                                .frame(width: 80, height: 80)
                                .scaleEffect(backgroundRaw == bg.rawValue ? 1.05 : 1.0)
                                .overlay(
                                    ZStack {
                                        // Light border for visibility
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.secondary, lineWidth: 1)
                                        // Highlight selected
                                        if backgroundRaw == bg.rawValue {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeManager.selected.accent,
                                                        lineWidth: 6)
                                        }
                                    }
                                )
                                .shadow(
                                    color: backgroundRaw == bg.rawValue
                                        ? themeManager.selected.accent.opacity(0.5)
                                        : Color.black.opacity(0.1),
                                    radius: backgroundRaw == bg.rawValue ? 12 : 2
                                )
                                .animation(.easeInOut(duration: 0.2), value: backgroundRaw)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        backgroundRaw = bg.rawValue
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)

                Spacer()

                // Done Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.selected.accent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager.shared)
    }
}
#endif

