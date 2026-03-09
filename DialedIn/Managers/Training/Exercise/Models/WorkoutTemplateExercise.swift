//
//  WorkoutTemplateExercise.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/02/2026.
//

import Foundation

struct WorkoutTemplateExercise: DataSyncModelProtocol, Equatable, Hashable {
    var id: String = UUID().uuidString
    var exercise: ExerciseModel
    var setTargets: [SetTarget] = [SetTarget(setNumber: 1, setType: SetTargetSetType.standard)]
    var setRestTimers: Bool
        
    enum CodingKeys: String, CodingKey {
        case id
        case exercise
        case setTargets = "set_targets"
        case setRestTimers = "set_rest_timers"
    }
    
    static var mock: WorkoutTemplateExercise {
        mocks[0]
    }
    
    static var mocks: [WorkoutTemplateExercise] {
        var mocks: [WorkoutTemplateExercise] = []
        
        for exercise in ExerciseModel.mocks {
            mocks.append(WorkoutTemplateExercise(exercise: exercise, setRestTimers: false))
        }
        
        return mocks
    }
}
