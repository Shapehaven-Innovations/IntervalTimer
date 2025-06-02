//  PreconfiguredTemplates.swift
//  IntervalTimer
//
//  Defines a set of built‑in SessionRecord templates (HIIT, Tabata, HILT, Work‑to‑Rest),
//  each with a fixed UUID so we can reference and hide/delete them persistently.
//

import Foundation

/// Holds all “built‑in” SessionRecord templates. Each has a fixed UUID so that we can
/// track when the user deletes one (or toggles off the entire group).
enum PreconfiguredTemplates {
    // MARK: – Static UUIDs for each template
    static let hiitID        = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let tabataID      = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    static let hiltID        = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
    static let workToRestID  = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!

    /// A “fresh” date is used here only because SessionRecord requires one; the date field is never
    /// shown for preconfigured templates. Adjust durations & sets as desired per template spec.
    private static var now: Date { Date() }

    /// The four built‑in templates
    static let all: [SessionRecord] = [
        SessionRecord(
            id: hiitID,
            name: "HIIT",
            date: now,
            timerDuration: 30,
            restDuration: 15,
            sets: 10,
            intention: nil
        ),
        SessionRecord(
            id: tabataID,
            name: "Tabata",
            date: now,
            timerDuration: 20,
            restDuration: 10,
            sets: 8,
            intention: nil
        ),
        SessionRecord(
            id: hiltID,
            name: "HILT",
            date: now,
            timerDuration: 45,
            restDuration: 15,
            sets: 6,
            intention: nil
        ),
        SessionRecord(
            id: workToRestID,
            name: "Work‑to‑Rest",
            date: now,
            timerDuration: 60,
            restDuration: 30,
            sets: 5,
            intention: nil
        )
    ]

    /// Returns a Dictionary mapping each template’s UUID to the corresponding SessionRecord,
    /// for quick lookups.
    static let byID: [UUID: SessionRecord] = {
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }()
}
