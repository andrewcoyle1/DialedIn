//
//  LiveActivityUpdating.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/09/2025.
//

import Foundation

@MainActor
protocol LiveActivityUpdating: AnyObject {
    func startLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?
    )
    
    func updateLiveActivity(params: LiveActivityUpdateParams)
    
    func updateRestAndActive(
        isActive: Bool,
        restEndsAt: Date?,
        statusMessage: String?
    )
    
    func endLiveActivity(
        session: WorkoutSessionModel,
        isCompleted: Bool,
        statusMessage: String?
    )
}
