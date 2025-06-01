// SessionRecord.swift
// IntervalTimer
// Shared model for saved sessions, now including an optional intention.

import Foundation

struct SessionRecord: Identifiable, Codable {
    let id: UUID
    var name: String
    let date: Date
    let timerDuration: Int
    let restDuration: Int
    let sets: Int
    let intention: String?

    init(id: UUID = UUID(),
         name: String = "",
         date: Date,
         timerDuration: Int,
         restDuration: Int,
         sets: Int,
         intention: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.timerDuration = timerDuration
        self.restDuration = restDuration
        self.sets = sets
        self.intention = intention
    }
}

