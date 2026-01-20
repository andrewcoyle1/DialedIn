//
//  DayPlan.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

struct DayPlan: Identifiable {
    let id: String
    let authorId: String
    var name: String
    
    var exercises: [ExercisePlan] = []
    
    init(id: String, authorId: String, name: String, exercises: [ExercisePlan]) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.exercises = exercises
    }
    
    static var mock: DayPlan {
        mocks[0]
    }
    
    static var mocks: [DayPlan] {
        [
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Push Day A",
                exercises: [
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Seated Pin-Loaded Machine Incline Press",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.chest, .arms, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Neutral Grip Machine Fly",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.chest, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-20*86400),
                            dateModified: Date.now.addingTimeInterval(-8*86400),
                            clickCount: 8,
                            bookmarkCount: 3,
                            favouriteCount: 2
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Low Pulley Cable Rope Overhead Triceps Extension",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.arms],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-15*86400),
                            dateModified: Date.now.addingTimeInterval(-9*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Single Arm Cable Lateral Raise (With Cable In Front Of Body",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    )
                ]
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Pull Day A",
                exercises: [
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Seated Neutral Grip Cable Row",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.back, .arms, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Neutral Grip Weighted Pull Up",
                            description: nil,
                            instructions: [],
                            type: .weightedBodyweight,
                            muscleGroups: [.back, .arms],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Close Grip Ez Bar Preacher Curl",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.arms],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Sideways Single Arm Machine Reverse Fly",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.back, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    )
                ]
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Leg Day A",
                exercises: [
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Machine Pendulum Squat",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.legs],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Barbell Romanian Deadlift",
                            description: nil,
                            instructions: [],
                            type: .barbell,
                            muscleGroups: [.back, .legs],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Pin-Loaded Machine Leg Extension",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.legs],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Single Arm Cable Lateral Raise (With Cable In Front Of Body)",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    )
                ]
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Push Day B",
                exercises: [
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Barbell Bench Press",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.chest, .arms, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Weighted Chest Dip",
                            description: nil,
                            instructions: [],
                            type: .weightedBodyweight,
                            muscleGroups: [.chest, .arms, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Low Pulley Cable Rope Overhead Triceps Extension",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.arms],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    )
                ]
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Pull Day B",
                exercises: [
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Chest-Support Neutral Grip T-Bar Row",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.back, .arms, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Neutral Shoulder Width Grip Cable Lat Pulldown",
                            description: nil,
                            instructions: [],
                            type: .barbell,
                            muscleGroups: [.back, .arms, .shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Cable Face Pull",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.shoulders, .back, .arms],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Single Arm Cable Lateral Raise (With Cable In Front Of Body)",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.shoulders],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Close Grip Ez Bar Preacher Curl",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.arms],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    )
                ]
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Leg Day B",
                exercises: [
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Plate-Loaded Machine Hip Thrust (Starting From The Top)",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.legs],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Offset Dumbbell Rear Foot Elevated Split Squat",
                            description: nil,
                            instructions: [],
                            type: .dumbbell,
                            muscleGroups: [.legs],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    ),
                    ExercisePlan(
                        id: UUID().uuidString,
                        authorId: "user123",
                        exercise: ExerciseTemplateModel(
                            exerciseId: UUID().uuidString,
                            authorId: "user123",
                            name: "Lying Pin-Loaded Machine Hamstring Curl",
                            description: nil,
                            instructions: [],
                            type: .machine,
                            muscleGroups: [.legs],
                            imageURL: nil,
                            isSystemExercise: false,
                            dateCreated: Date.now.addingTimeInterval(-10*86400),
                            dateModified: Date.now.addingTimeInterval(-2*86400),
                            clickCount: 5,
                            bookmarkCount: 2,
                            favouriteCount: 1
                        )
                    )
                ]
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Rest",
                exercises: []
            )
        ]
    }
}
