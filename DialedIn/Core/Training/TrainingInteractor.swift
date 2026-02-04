//
//  TrainingInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol TrainingInteractor {
    var currentUser: UserModel? { get }
    var userImageUrl: String? { get }
    var activeTrainingProgram: TrainingProgram? { get }
    var activeSession: WorkoutSessionModel? { get }
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel]
    func getActiveTrainingProgram() async throws -> TrainingProgram?
    func trackEvent(event: LoggableEvent)
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel
    func getAuthId() throws -> String
    func addLocalWorkoutSession(session: WorkoutSessionModel) throws
    func startActiveSession(_ session: WorkoutSessionModel)
    func readLocalGymProfile(profileId: String) throws -> GymProfileModel
    func readRemoteGymProfile(profileId: String) async throws -> GymProfileModel
    func deleteTrainingProgram(program: TrainingProgram) async throws
}

extension CoreInteractor: TrainingInteractor { }
