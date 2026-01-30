//
//  ExercisePlan.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

struct ExercisePlan: Identifiable, Codable {
    
    let id: String
    let authorId: String
    
    let exercise: ExerciseModel
    
    // TODO: Add sets etc.
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case exercise
    }
    
    static var mock: ExercisePlan {
        mocks[0]
    }
    
    static var mocks: [ExercisePlan] {
        var mocks: [ExercisePlan] = []
        for mock in ExerciseModel.mocks {
            mocks.append(
                ExercisePlan(
                    id: UUID().uuidString,
                    authorId: "user123",
                    exercise: mock
                )
            )
        }
        return mocks
    }
}
