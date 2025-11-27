//
//  DevSettingsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol DevSettingsInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var currentTrainingPlan: TrainingPlan? { get }
    var activeSession: WorkoutSessionModel? { get }
    func updateAppState(showTabBarView: Bool)
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel]
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel]
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
    func getCurrentWeek() -> TrainingWeek?
    func getTodaysWorkouts() -> [ScheduledWorkout]
    func getAllLocalWorkoutSessions() throws -> [WorkoutSessionModel]
    func updatePlan(_ plan: TrainingPlan) async throws
    func trackEvent(event: LoggableEvent)
    func getWorkoutSession(id: String) async throws -> WorkoutSessionModel
    func clearAllTrainingPlanLocalData() throws
    func deleteAllLocalWorkoutSessionsForAuthor(authorId: String) throws
    func logOut()
    func signOut() throws
}

extension CoreInteractor: DevSettingsInteractor { }
