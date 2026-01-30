//
//  DayPlan.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

struct DayPlan: Identifiable, Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case name
        case exercises
    }
    
    static var mock: DayPlan {
        mocks[0]
    }
    
    static var mocks: [DayPlan] {
        let samples = ExerciseModel.mocks
        let makePlans: ([ExerciseModel]) -> [ExercisePlan] = { exercises in
            exercises.map { exercise in
                ExercisePlan(id: UUID().uuidString, authorId: "user123", exercise: exercise)
            }
        }

        return [
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Push Day A",
                exercises: makePlans(Array(samples.prefix(3)))
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Pull Day A",
                exercises: makePlans(Array(samples.dropFirst(3).prefix(3)))
            ),
            DayPlan(
                id: UUID().uuidString,
                authorId: "user123",
                name: "Leg Day A",
                exercises: makePlans(Array(samples.dropFirst(6).prefix(3)))
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
