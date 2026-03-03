//
//  AnalyticsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import Foundation

@MainActor
protocol AnalyticsInteractor: GlobalInteractor {
    var userImageUrl: String? { get }
    var activeTests: ActiveABTests { get }
    var userId: String? { get }
    var currentUser: UserModel? { get }
    var bodyMeasurements: [BodyMeasurementEntry] { get }
    var auth: UserAuthInfo? { get }
    var workoutSessions: [WorkoutSessionModel] { get }
    var allExercises: [ExerciseModel] { get }
    var systemExercises: [ExerciseModel] { get }
    var userExercises: [ExerciseModel] { get }
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget?
    func estimateTDEE(user: UserModel?) -> Double
    var stepsHistory: [StepsModel] { get }
    func backfillStepsFromHealthKit() async
}

extension CoreInteractor: AnalyticsInteractor { }
