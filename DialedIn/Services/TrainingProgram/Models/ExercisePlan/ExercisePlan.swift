//
//  ExercisePlan.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import Foundation

struct ExercisePlan: Identifiable {
    
    let id: String
    let authorId: String
    
    let exercise: ExerciseTemplateModel
    
    // TODO: Add sets etc.
    
    static var mock: ExercisePlan {
        mocks[0]
    }
    
    static var mocks: [ExercisePlan] {
        var mocks: [ExercisePlan] = []
        for mock in ExerciseTemplateModel.mocks {
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
