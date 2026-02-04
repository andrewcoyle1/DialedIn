//
//  SetTrackerRowInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol SetTrackerRowInteractor {
    var activeSession: WorkoutSessionModel? { get }
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws
    var restEndTime: Date? { get }
    
    func startRest(durationSeconds: Int, session: WorkoutSessionModel, currentExerciseIndex: Int)
    func schedulePushNotification(identifier: String, title: String, body: String, date: Date) async throws
    
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
}

extension CoreInteractor: SetTrackerRowInteractor { }
