//
//  WorkoutExerciseModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation

struct WorkoutExerciseModel: Identifiable, Codable, Hashable {
    let id: String
    let authorId: String
    let templateId: String
    let name: String
    let trackingMode: TrackingMode
    var index: Int
    var notes: String?
    var imageName: String?
    var sets: [WorkoutSetModel]
    
    init(id: String, authorId: String, templateId: String, name: String, trackingMode: TrackingMode, index: Int, notes: String? = nil, imageName: String? = nil, sets: [WorkoutSetModel]) {
        self.id = id
        self.authorId = authorId
        self.templateId = templateId
        self.name = name
        self.trackingMode = trackingMode
        self.index = index
        self.notes = notes
        self.imageName = imageName
        self.sets = sets
    }

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case templateId = "template_id"
        case name
        case trackingMode = "tracking_mode"
        case index
        case notes
        case imageName = "image_name"
        case sets
    }
    
    static var mock: WorkoutExerciseModel {
        mocks[0]
    }
    
    static var mocks: [WorkoutExerciseModel] {
        [
            WorkoutExerciseModel(id: "1", authorId: "1", templateId: "1", name: "Bench Press", trackingMode: .weightReps, index: 1, notes: "Notes", sets: [WorkoutSetModel.mocks[0]]),
            WorkoutExerciseModel(id: "2", authorId: "1", templateId: "2", name: "Squat", trackingMode: .weightReps, index: 2, notes: "Notes", sets: [WorkoutSetModel.mocks[1]]),
            WorkoutExerciseModel(id: "3", authorId: "1", templateId: "3", name: "Deadlift", trackingMode: .weightReps, index: 3, notes: "Notes", sets: [WorkoutSetModel.mocks[2]]),
            WorkoutExerciseModel(id: "4", authorId: "1", templateId: "4", name: "Pull-Up", trackingMode: .weightReps, index: 4, notes: "Notes", sets: [WorkoutSetModel.mocks[3]]),
            WorkoutExerciseModel(id: "5", authorId: "1", templateId: "5", name: "Push-Up", trackingMode: .weightReps, index: 5, notes: "Notes", sets: [WorkoutSetModel.mocks[4]]),
            WorkoutExerciseModel(id: "6", authorId: "1", templateId: "6", name: "Dumbbell Curl", trackingMode: .weightReps, index: 6, notes: "Notes", sets: [WorkoutSetModel.mocks[5]]),
            WorkoutExerciseModel(id: "7", authorId: "1", templateId: "7", name: "Tricep Rope Pushdown", trackingMode: .weightReps, index: 7, notes: "Notes", sets: [WorkoutSetModel.mocks[6]]),
            WorkoutExerciseModel(id: "8", authorId: "1", templateId: "8", name: "Leg Press", trackingMode: .weightReps, index: 8, notes: "Notes", sets: [WorkoutSetModel.mocks[7]]),
            WorkoutExerciseModel(id: "9", authorId: "1", templateId: "9", name: "Plank", trackingMode: .weightReps, index: 9, notes: "Notes", sets: [WorkoutSetModel.mocks[8]]),
            WorkoutExerciseModel(id: "10", authorId: "1", templateId: "10", name: "Treadmill Run", trackingMode: .distanceTime, index: 10, notes: "Notes", sets: [WorkoutSetModel.mocks[9]])
        ]
    }
}
