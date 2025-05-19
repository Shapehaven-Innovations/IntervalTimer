// WorkoutLogView.swift
// IntervalTimer
// Detailed list of every session, now with theming from Theme.swift

import SwiftUI

struct WorkoutLogView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var history: [SessionRecord] = []
    @State private var showingClearAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, record in
                        WorkoutCard(record: record, index: index)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Workout Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") { showingClearAlert = true }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .alert("Clear Workout Log?", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) { clearHistory() }
            } message: {
                Text("This cannot be undone.")
            }
            .onAppear(perform: loadHistory)
        }
    }

    // MARK: – Data

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "sessionHistory"),
           let decoded = try? JSONDecoder()
             .decode([SessionRecord].self, from: data) {
            history = decoded.sorted { $0.date > $1.date }
        }
    }

    private func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "sessionHistory")
    }
}

// MARK: – Workout Card

private struct WorkoutCard: View {
    let record: SessionRecord
    let index: Int

    // pick a background from Theme by cycling index
    private var backgroundTint: Color {
        Theme.cardBackgrounds[index % Theme.cardBackgrounds.count].opacity(0.1)
    }
    private var shadowTint: Color {
        Theme.cardBackgrounds[index % Theme.cardBackgrounds.count].opacity(0.2)
    }
    private var foreground: Color {
        Theme.accent
    }

    /// Title: saved name if non‑empty, otherwise fallback to "YYYYDDMM"
    private var displayName: String {
        if !record.name.trimmingCharacters(in: .whitespaces).isEmpty {
            return record.name
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyyddMM"
            return fmt.string(from: record.date)
        }
    }

    /// Subtitle: day‑of‑week, date & time
    private var subtitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        return fmt.string(from: record.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(displayName)
                    .font(.headline)
                Spacer()
                Text(totalTimeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Label(format(record.timerDuration), systemImage: "flame.fill")
                Spacer()
                Label(format(record.restDuration), systemImage: "bed.double.fill")
                Spacer()
                Label("\(record.sets)x", systemImage: "repeat.circle.fill")
            }
            .font(.footnote)
            .foregroundColor(foreground)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(backgroundTint)
        )
        .shadow(color: shadowTint, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: – Helpers

    private var totalTimeString: String {
        let totalRest = max(0, record.restDuration * (record.sets - 1))
        let total    = record.timerDuration * record.sets + totalRest
        return format(total)
    }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct WorkoutLogView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutLogView()
    }
}

