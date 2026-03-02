//
//  TrainingInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol TrainingInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var userImageUrl: String? { get }
    var activeTrainingProgram: TrainingProgram? { get }
    var activeSession: WorkoutSessionModel? { get }
    var workoutSessions: [WorkoutSessionModel] { get }
    var favouriteGymProfile: GymProfileModel? { get }
    func getAuthId() throws -> String
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func updateActiveSession(_ session: WorkoutSessionModel) throws
    func saveWorkoutSession(_ session: WorkoutSessionModel) async throws

    func deleteTrainingProgram(programId: String) async throws
    func deleteActiveSession() throws
    func getPreference(templateId: String) -> ExerciseUnitPreference
}

extension CoreInteractor: TrainingInteractor { }
