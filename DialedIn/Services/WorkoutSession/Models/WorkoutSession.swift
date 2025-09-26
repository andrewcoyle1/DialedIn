//
//  WorkoutSession.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation
import IdentifiableByString

struct WorkoutSession: Identifiable, Codable, StringIdentifiable, Hashable {
    let id: String
    let userId: String
    let dateCreated: Date
    var endedAt: Date?
    var notes: String?
    var exercises: [WorkoutExercise]
    
    init(
        id: String,
        userId: String,
        dateCreated: Date,
        endedAt: Date? = nil,
        notes: String? = nil,
        exercises: [WorkoutExercise]
    ) {
        self.id = id
        self.userId = userId
        self.dateCreated = dateCreated
        self.endedAt = endedAt
        self.notes = notes
        self.exercises = exercises
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case dateCreated = "date_created"
        case endedAt = "ended_at"
        case notes
        case exercises
    }
    
    static var mock: WorkoutSession {
        mocks[0]
    }
    
    static var mocks: [WorkoutSession] {
        [
            WorkoutSession(
                id: "1",
                userId: "1",
                dateCreated: Date().addingTimeInterval(-86400 * 1),
                endedAt: Date().addingTimeInterval(-86400 * 1 + 3600),
                notes: "Felt strong today. Focused on form.",
                exercises: [
                    WorkoutExercise.mock,
                    WorkoutExercise(
                        id: "ex2",
                        templateId: "2",
                        name: "Squat",
                        trackingMode: .weightReps,
                        notes: "Went heavier than usual.",
                        sets: [WorkoutSet.mocks[1], WorkoutSet.mocks[2]]
                    )
                ]
            ),
            WorkoutSession(
                id: "2",
                userId: "2",
                dateCreated: Date().addingTimeInterval(-86400 * 2),
                endedAt: Date().addingTimeInterval(-86400 * 2 + 2700),
                notes: "Quick session, focused on upper body.",
                exercises: [
                    WorkoutExercise(
                        id: "ex3",
                        templateId: "3",
                        name: "Deadlift",
                        trackingMode: .weightReps,
                        notes: nil,
                        sets: [WorkoutSet.mocks[2], WorkoutSet.mocks[3]]
                    )
                ]
            ),
            WorkoutSession(
                id: "3",
                userId: "3",
                dateCreated: Date().addingTimeInterval(-86400 * 3),
                endedAt: nil,
                notes: nil,
                exercises: [
                    WorkoutExercise(
                        id: "ex4",
                        templateId: "4",
                        name: "Pull-Up",
                        trackingMode: .repsOnly,
                        notes: "Tried a new grip.",
                        sets: [WorkoutSet.mocks[3]]
                    ),
                    WorkoutExercise.mock
                ]
            ),
            WorkoutSession(
                id: "4",
                userId: "4",
                dateCreated: Date().addingTimeInterval(-86400 * 4),
                endedAt: Date().addingTimeInterval(-86400 * 4 + 1800),
                notes: "Short cardio session.",
                exercises: [
                    WorkoutExercise(
                        id: "ex5",
                        templateId: "10",
                        name: "Treadmill Run",
                        trackingMode: .timeOnly,
                        notes: "Increased speed for last 5 minutes.",
                        sets: [WorkoutSet.mocks[2]]
                    )
                ]
            ),
            WorkoutSession(
                id: "5",
                userId: "5",
                dateCreated: Date().addingTimeInterval(-86400 * 5),
                endedAt: nil,
                notes: "Leg day. Exhausted!",
                exercises: [
                    WorkoutExercise(
                        id: "ex6",
                        templateId: "8",
                        name: "Leg Press",
                        trackingMode: .weightReps,
                        notes: nil,
                        sets: [WorkoutSet.mocks[1], WorkoutSet.mocks[2], WorkoutSet.mocks[3]]
                    )
                ]
            ),
            WorkoutSession(
                id: "6",
                userId: "6",
                dateCreated: Date().addingTimeInterval(-86400 * 6),
                endedAt: Date().addingTimeInterval(-86400 * 6 + 3200),
                notes: nil,
                exercises: [
                    WorkoutExercise.mock
                ]
            ),
            WorkoutSession(
                id: "7",
                userId: "7",
                dateCreated: Date().addingTimeInterval(-86400 * 7),
                endedAt: nil,
                notes: "Focused on arms.",
                exercises: [
                    WorkoutExercise(
                        id: "ex7",
                        templateId: "6",
                        name: "Dumbbell Curl",
                        trackingMode: .weightReps,
                        notes: "Used new dumbbells.",
                        sets: [WorkoutSet.mocks[0], WorkoutSet.mocks[1]]
                    ),
                    WorkoutExercise(
                        id: "ex8",
                        templateId: "7",
                        name: "Tricep Rope Pushdown",
                        trackingMode: .weightReps,
                        notes: nil,
                        sets: [WorkoutSet.mocks[2]]
                    )
                ]
            ),
            WorkoutSession(
                id: "8",
                userId: "8",
                dateCreated: Date().addingTimeInterval(-86400 * 8),
                endedAt: Date().addingTimeInterval(-86400 * 8 + 1500),
                notes: "Core and stability work.",
                exercises: [
                    WorkoutExercise(
                        id: "ex9",
                        templateId: "9",
                        name: "Plank",
                        trackingMode: .timeOnly,
                        notes: "Held for 1 minute.",
                        sets: [WorkoutSet.mocks[2]]
                    )
                ]
            ),
            WorkoutSession(
                id: "9",
                userId: "9",
                dateCreated: Date().addingTimeInterval(-86400 * 9),
                endedAt: nil,
                notes: nil,
                exercises: [
                    WorkoutExercise.mock
                ]
            ),
            WorkoutSession(
                id: "10",
                userId: "10",
                dateCreated: Date().addingTimeInterval(-86400 * 10),
                endedAt: Date().addingTimeInterval(-86400 * 10 + 2000),
                notes: "Pushed hard on cardio.",
                exercises: [
                    WorkoutExercise(
                        id: "ex10",
                        templateId: "10",
                        name: "Treadmill Run",
                        trackingMode: .distanceTime,
                        notes: "Personal best distance.",
                        sets: [WorkoutSet.mocks[2], WorkoutSet.mocks[3]]
                    )
                ]
            )
        ]
    }
}
