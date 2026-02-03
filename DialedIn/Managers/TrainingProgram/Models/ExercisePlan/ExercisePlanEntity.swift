//
//  ExercisePlanEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import SwiftUI
import SwiftData

@Model
class ExercisePlanEntity {
    
    @Attribute(.unique) var id: String
    var authorId: String
    /// Persist a snapshot of the exercise to avoid cross-store SwiftData relationships.
    var exerciseData: Data
    var setTargets: Data
    var setRestTimers: Bool
    
    @Relationship var dayPlan: DayPlanEntity?
    
    @MainActor
    init(from model: WorkoutTemplateExercise) {
        self.id = model.id
        self.authorId = model.exercise.authorId
        self.exerciseData = Self.encode(model.exercise)
        self.setTargets = Self.encode(model.setTargets)
        self.setRestTimers = model.setRestTimers
        self.dayPlan = nil
    }
    
    @MainActor
    func toModel() -> WorkoutTemplateExercise {
        WorkoutTemplateExercise(
            id: id,
            exercise: Self.decode(exerciseData, fallback: ExerciseModel.mock),
            setTargets: Self.decode(setTargets, fallback: [SetTarget]()),
            setRestTimers: setRestTimers
        )
    }

    @MainActor
    private static func encode<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder().encode(value)) ?? Data()
    }

    @MainActor
    private static func decode<T: Decodable>(_ data: Data, fallback: T) -> T {
        (try? JSONDecoder().decode(T.self, from: data)) ?? fallback
    }
}
