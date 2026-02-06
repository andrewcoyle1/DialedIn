//
//  WeightEntryEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/02/2026.
//

import SwiftUI
import SwiftData

@Model
class WeightEntryEntity {
    @Attribute(.unique) var id: String
    var authorId: String
    var weightKg: Double
    var bodyFatPercentage: Double?
    var date: Date
    var source: WeightSource
    var notes: String?
    var dateCreated: Date
    var deletedAt: Date?
    var healthKitUUID: UUID?

    init(from model: WeightEntry) {
        self.id = model.id
        self.authorId = model.authorId
        self.weightKg = model.weightKg
        self.bodyFatPercentage = model.bodyFatPercentage
        self.date = model.date
        self.source = model.source
        self.notes = model.notes
        self.dateCreated = model.dateCreated
        self.deletedAt = model.deletedAt
        self.healthKitUUID = model.healthKitUUID
    }
    
    @MainActor
    func toModel() -> WeightEntry {
        WeightEntry(
            id: id,
            authorId: authorId,
            weightKg: weightKg,
            bodyFatPercentage: bodyFatPercentage,
            date: date,
            source: source,
            notes: notes,
            dateCreated: dateCreated,
            deletedAt: deletedAt,
            healthKitUUID: healthKitUUID
        )
    }
}
