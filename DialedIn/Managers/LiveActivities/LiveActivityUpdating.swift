//
//  LiveActivityUpdating.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/09/2025.
//

import Foundation

@MainActor
protocol LiveActivityUpdating: AnyObject {
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?
    )
    
    func updateLiveActivity(params: LiveActivityUpdateParams)
    
    func updateRestAndActive(
        isActive: Bool,
        restEndsAt: Date?
    )
    
    func endLiveActivity(
        session: WorkoutSessionModel,
        isCompleted: Bool
    )
}
