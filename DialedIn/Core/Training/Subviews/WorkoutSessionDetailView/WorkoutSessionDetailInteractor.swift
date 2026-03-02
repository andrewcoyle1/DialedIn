//
//  WorkoutSessionDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol WorkoutSessionDetailInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func saveWorkoutSession(_ session: WorkoutSessionModel) async throws
    func getPreference(templateId: String) -> ExerciseUnitPreference
    func setPreference(weightUnit: ExerciseWeightUnit?, distanceUnit: ExerciseDistanceUnit?, for templateId: String)
    func deleteWorkoutSession(id: String) async throws
}

extension CoreInteractor: WorkoutSessionDetailInteractor { }
