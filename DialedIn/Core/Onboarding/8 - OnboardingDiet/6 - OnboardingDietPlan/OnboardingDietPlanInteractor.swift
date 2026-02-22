//
//  OnboardingDietPlanInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingDietPlanInteractor {
    var currentUser: UserModel? { get }
    func computeDietPlan(user: UserModel?, builder: DietPlanBuilder) -> DietPlan
    func saveDietPlan(plan: DietPlan) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingDietPlanInteractor { }
