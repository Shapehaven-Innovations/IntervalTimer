
//
//  Models.swift
//  IntervalTimer
//

import Foundation

/// A record of one workout‐intention (state of mind) entry.
public struct IntentRecord: Identifiable, Codable {
    public let id: UUID
    public let date: Date
    public let state: String

    public init(date: Date, state: String) {
        self.id    = UUID()
        self.date  = date
        self.state = state
    }
}
