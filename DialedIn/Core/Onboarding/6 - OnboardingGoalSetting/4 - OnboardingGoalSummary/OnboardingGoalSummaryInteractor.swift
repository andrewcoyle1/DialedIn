//
//  OnboardingGoalSummaryInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingGoalSummaryInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    func createGoal(
        userId: String,
        objective: OverarchingObjective,
        startingWeightKg: Double,
        targetWeightKg: Double,
        weeklyChangeKg: Double
    ) async throws -> WeightGoal
    func updateCurrentGoalId(goalId: String?) async throws
}

extension CoreInteractor: OnboardingGoalSummaryInteractor { }
