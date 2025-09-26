//
//  WorkoutExercise.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation
import IdentifiableByString

struct WorkoutExercise: Identifiable, Codable, StringIdentifiable, Hashable {
    let id: String
    let templateId: String
    let name: String
    let trackingMode: TrackingMode
    var notes: String?
    var sets: [WorkoutSet]
    
    init(id: String, templateId: String, name: String, trackingMode: TrackingMode, notes: String? = nil, sets: [WorkoutSet]) {
        self.id = id
        self.templateId = templateId
        self.name = name
        self.trackingMode = trackingMode
        self.notes = notes
        self.sets = sets
    }

    enum CodingKeys: String, CodingKey {
        case id
        case templateId = "template_id"
        case name
        case trackingMode = "tracking_mode"
        case notes
        case sets
    }
    
    static var mock: WorkoutExercise {
        mocks[0]
    }
    
    static var mocks: [WorkoutExercise] {
        [
            WorkoutExercise(id: "1", templateId: "1", name: "Bench Press", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[0]]),
            WorkoutExercise(id: "2", templateId: "2", name: "Squat", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[1]]),
            WorkoutExercise(id: "3", templateId: "3", name: "Deadlift", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[2]]),
            WorkoutExercise(id: "4", templateId: "4", name: "Pull-Up", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[3]]),
            WorkoutExercise(id: "5", templateId: "5", name: "Push-Up", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[4]]),
            WorkoutExercise(id: "6", templateId: "6", name: "Dumbbell Curl", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[5]]),
            WorkoutExercise(id: "7", templateId: "7", name: "Tricep Rope Pushdown", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[6]]),
            WorkoutExercise(id: "8", templateId: "8", name: "Leg Press", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[7]]),
            WorkoutExercise(id: "9", templateId: "9", name: "Plank", trackingMode: .weightReps, notes: "Notes", sets: [WorkoutSet.mocks[8]]),
            WorkoutExercise(id: "10", templateId: "10", name: "Treadmill Run", trackingMode: .distanceTime, notes: "Notes", sets: [WorkoutSet.mocks[9]])
        ]
    }
}
