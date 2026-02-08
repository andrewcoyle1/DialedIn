//
//  GoalProgressInteractor.swift
//  DialedIn
//

import SwiftUI

@MainActor
protocol GoalProgressInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    var measurementHistory: [BodyMeasurementEntry] { get }
    func getActiveGoal(userId: String) async throws -> WeightGoal?
    func readAllLocalWeightEntries() throws -> [BodyMeasurementEntry]
}

extension CoreInteractor: GoalProgressInteractor { }
