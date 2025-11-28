//
//  WorkoutSessionDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

protocol WorkoutSessionDetailInteractor {
    var currentUser: UserModel? { get }
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws
    func updateWorkoutSession(session: WorkoutSessionModel) async throws
    func getPreference(templateId: String) -> ExerciseUnitPreference
    func setPreference(weightUnit: ExerciseWeightUnit?, distanceUnit: ExerciseDistanceUnit?, for templateId: String)
    func deleteLocalWorkoutSession(id: String) throws
    func deleteWorkoutSession(id: String) async throws
    func markWorkoutIncompleteIfSessionDeleted(scheduledWorkoutId: String, sessionId: String) async throws
}

extension CoreInteractor: WorkoutSessionDetailInteractor { }
