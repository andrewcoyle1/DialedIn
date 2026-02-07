//
//  DashboardInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol DashboardInteractor {
    var userImageUrl: String? { get }
    var activeTests: ActiveABTests { get }
    var userId: String? { get }
    var currentUser: UserModel? { get }
    var measurementHistory: [BodyMeasurementEntry] { get }
    var auth: UserAuthInfo? { get }
    func trackEvent(event: LoggableEvent)
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
    func readAllRemoteWeightEntries(userId: String) async throws -> [BodyMeasurementEntry]
    func getLocalWorkoutSessionsForAuthor(authorId: String, limitTo: Int) throws -> [WorkoutSessionModel]
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseModel]
    func getSystemExerciseTemplates() throws -> [ExerciseModel]
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel]
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func estimateTDEE(user: UserModel?) -> Double
    func readAllLocalStepsEntries() throws -> [StepsModel]
    var stepsHistory: [StepsModel] { get }
    func backfillStepsFromHealthKit() async
}

extension CoreInteractor: DashboardInteractor { }
