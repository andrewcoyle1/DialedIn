//
//  ExerciseHistorySetEntity.swift
//  DialedIn
//
//  Created by AI Assistant on 28/09/2025.
//

import SwiftUI
import SwiftData

@Model
class ExerciseHistorySetEntity {
    var id: String
    var authorId: String
    var index: Int
    var reps: Int?
    var weightKg: Double?
    var durationSec: Int?
    var distanceMeters: Double?
    var rpe: Double?
    var isWarmup: Bool
    var dateCreated: Date
    var completedAt: Date?
    @Relationship var entry: ExerciseHistoryEntryEntity?

    init(from model: WorkoutSetModel) {
        self.id = model.id
        self.authorId = model.authorId
        self.index = model.index
        self.reps = model.reps
        self.weightKg = model.weightKg
        self.durationSec = model.durationSec
        self.distanceMeters = model.distanceMeters
        self.rpe = model.rpe
        self.isWarmup = model.isWarmup
        self.completedAt = model.completedAt
        self.dateCreated = model.dateCreated
    }

    @MainActor
    func toModel() -> WorkoutSetModel {
        WorkoutSetModel(
            id: id,
            authorId: authorId,
            index: index,
            reps: reps,
            weightKg: weightKg,
            durationSec: durationSec,
            distanceMeters: distanceMeters,
            rpe: rpe,
            isWarmup: isWarmup,
            completedAt: completedAt,
            dateCreated: dateCreated
        )
    }
}
