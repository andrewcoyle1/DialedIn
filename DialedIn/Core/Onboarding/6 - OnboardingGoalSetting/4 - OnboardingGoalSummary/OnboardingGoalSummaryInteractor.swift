//
//  OnboardingGoalSummaryInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingGoalSummaryInteractor {
    var currentUser: UserModel? { get }
    func createGoal(
        userId: String,
        objective: OverarchingObjective,
        startingWeightKg: Double,
        targetWeightKg: Double,
        weeklyChangeKg: Double
    ) async throws -> WeightGoal
    func updateOnboardingStep(step: OnboardingStep) async throws
    func updateCurrentGoalId(goalId: String?) async throws
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingGoalSummaryInteractor { }
