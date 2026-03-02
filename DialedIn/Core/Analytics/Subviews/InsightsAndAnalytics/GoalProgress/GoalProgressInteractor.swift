//
//  GoalProgressInteractor.swift
//  DialedIn
//

import SwiftUI

@MainActor
protocol GoalProgressInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    var bodyMeasurements: [BodyMeasurementEntry] { get }
}

extension CoreInteractor: GoalProgressInteractor { }
