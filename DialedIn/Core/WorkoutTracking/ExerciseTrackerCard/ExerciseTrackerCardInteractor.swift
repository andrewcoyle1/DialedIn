//
//  ExerciseTrackerCardInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import Foundation

protocol ExerciseTrackerCardInteractor {
    var currentUser: UserModel? { get }
    var activeSession: WorkoutSessionModel? { get }
    var restEndTime: Date? { get }
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws

    /// Get the exercise unit preference (weight, distance, etc.) for a template.
    func getPreference(templateId: String) -> ExerciseUnitPreference

    /// Set user's preferred weight unit for a particular exercise template.
    func setWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String)

    /// Set user's preferred distance unit for a particular exercise template.
    func setDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String)

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
    
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws
}

extension CoreInteractor: ExerciseTrackerCardInteractor { }
