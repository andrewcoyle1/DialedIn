//
//  WorkoutSession.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation

struct WorkoutSessionModel: Identifiable, Codable, Hashable {
    let id: String
    let authorId: String
    var name: String
    let workoutTemplateId: String?
    let scheduledWorkoutId: String?
    let trainingPlanId: String?
    let dateCreated: Date
    private(set) var dateModified: Date
    private(set) var endedAt: Date?
    var notes: String?
    private(set) var exercises: [WorkoutExerciseModel]
    
    init(
        id: String,
        authorId: String,
        name: String,
        workoutTemplateId: String? = nil,
        scheduledWorkoutId: String? = nil,
        trainingPlanId: String? = nil,
        dateCreated: Date,
        dateModified: Date? = nil,
        endedAt: Date? = nil,
        notes: String? = nil,
        exercises: [WorkoutExerciseModel]
    ) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.workoutTemplateId = workoutTemplateId
        self.scheduledWorkoutId = scheduledWorkoutId
        self.trainingPlanId = trainingPlanId
        self.dateCreated = dateCreated
        self.dateModified = dateModified ?? dateCreated
        self.endedAt = endedAt
        self.notes = notes
        self.exercises = exercises
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name = "name"
        case workoutTemplateId = "workout_template_id"
        case scheduledWorkoutId = "scheduled_workout_id"
        case trainingPlanId = "training_plan_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case endedAt = "ended_at"
        case notes
        case exercises
    }

    init(id: String = UUID().uuidString, authorId: String, template: WorkoutTemplateModel, notes: String? = nil, scheduledWorkoutId: String? = nil, trainingPlanId: String? = nil) {
        self.id = id
        self.authorId = authorId
        self.name = template.name
        self.workoutTemplateId = template.id
        self.scheduledWorkoutId = scheduledWorkoutId
        self.trainingPlanId = trainingPlanId
        self.dateCreated = .now
        self.dateModified = .now
        self.endedAt = nil
        self.notes = notes
        self.exercises = template.exercises.enumerated().map { (idx, exerciseTemplate) in
            let mode = WorkoutSessionModel.trackingMode(for: exerciseTemplate.type)
            let sets = WorkoutSessionModel.defaultSets(trackingMode: mode, authorId: authorId)
            let imageName = Constants.exerciseImageName(for: exerciseTemplate.name)
            return WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: authorId,
                templateId: exerciseTemplate.exerciseId,
                name: exerciseTemplate.name,
                trackingMode: mode,
                index: idx + 1,
                notes: nil,
                imageName: imageName,
                sets: sets
            )
        }
    }

    static func trackingMode(for category: ExerciseCategory) -> TrackingMode {
        switch category {
        case .repsOnly:
            return .repsOnly
        case .cardio:
            return .distanceTime
        case .duration:
            return .timeOnly
        case .none:
            return .repsOnly
        case .barbell, .dumbbell, .kettlebell, .medicineBall, .machine, .cable, .weightedBodyweight, .assistedBodyweight:
            return .weightReps
        }
    }

    // Mutating methods for workout tracker
    mutating func updateExercises(_ exercises: [WorkoutExerciseModel]) {
        self.exercises = exercises
        self.dateModified = Date()
    }
    
    mutating func endSession(at date: Date) {
        self.endedAt = date
        self.dateModified = date
    }
    
    static func defaultSets(trackingMode: TrackingMode, authorId: String) -> [WorkoutSetModel] {
        switch trackingMode {
        case .weightReps:
            return [0, 1, 2].map { index in
                WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: index + 1, reps: nil,
                                weightKg: nil, durationSec: nil, distanceMeters: nil, rpe: nil,
                                isWarmup: index == 0, completedAt: nil, dateCreated: .now)
            }
        case .repsOnly:
            return [0, 1, 2].map { index in
                WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: index + 1, reps: nil,
                                weightKg: nil, durationSec: nil, distanceMeters: nil, rpe: nil,
                                isWarmup: index == 0, completedAt: nil, dateCreated: .now)
            }
        case .timeOnly:
            return [WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: 1, reps: nil,
                                    weightKg: nil, durationSec: 60, distanceMeters: nil, rpe: nil,
                                    isWarmup: false, completedAt: nil, dateCreated: .now)]
        case .distanceTime:
            return [WorkoutSetModel(id: UUID().uuidString, authorId: authorId, index: 1, reps: nil,
                                    weightKg: nil, durationSec: 120, distanceMeters: 400, rpe: nil,
                                    isWarmup: false, completedAt: nil, dateCreated: .now)]
        }
    }
    
    static var mock: WorkoutSessionModel {
        mocks[0]
    }
    
    static var mocks: [WorkoutSessionModel] {
        // Ensure mock sessions belong to the preview/mock user and are completed so they appear in history
        let uid = "uid"
        var session1 = WorkoutSessionModel(id: "session-1", authorId: uid, template: WorkoutTemplateModel.mocks[0])
        session1.endSession(at: session1.dateCreated.addingTimeInterval(45 * 60))
        var session2 = WorkoutSessionModel(id: "session-2", authorId: uid, template: WorkoutTemplateModel.mocks[1])
        session2.endSession(at: session2.dateCreated.addingTimeInterval(30 * 60))
        var session3 = WorkoutSessionModel(id: "session-3", authorId: uid, template: WorkoutTemplateModel.mocks[2])
        session3.endSession(at: session3.dateCreated.addingTimeInterval(60 * 60))
        return [session1, session2, session3]
    }
}
