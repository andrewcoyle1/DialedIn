//
//  DevSettingsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol DevSettingsInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var activeTests: ActiveABTests { get }
    func override(updatedTests: ActiveABTests) throws
    var activeSession: WorkoutSessionModel? { get }
    func updateAppState(showTabBarView: Bool)
    func getAllLocalExerciseTemplates() throws -> [ExerciseModel]
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel]
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel]
    func trackEvent(event: LoggableEvent)
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws
    func clearAllLocalStepsData() throws
    func signOut() async throws
}

extension CoreInteractor: DevSettingsInteractor { }

extension OnbInteractor: DevSettingsInteractor { }
