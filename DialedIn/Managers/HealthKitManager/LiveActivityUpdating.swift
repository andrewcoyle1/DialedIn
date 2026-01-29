//
//  LiveActivityUpdating.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/09/2025.
//

import Foundation

protocol LiveActivityUpdating: AnyObject {
    func startLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?
    )
    
    // swiftlint:disable:next function_parameter_count
    func updateLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?,
        totalVolumeKg: Double?,
        elapsedTime: TimeInterval?
    )
    
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
    
    var isLiveActivityActive: Bool { get }
}
