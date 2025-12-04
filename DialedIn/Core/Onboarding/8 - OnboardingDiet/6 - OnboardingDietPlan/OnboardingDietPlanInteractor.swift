//
//  OnboardingDietPlanInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingDietPlanInteractor {
    var currentUser: UserModel? { get }
    var currentTrainingPlan: TrainingPlan? { get }
    func computeDietPlan(user: UserModel?, builder: DietPlanBuilder) -> DietPlan
    func saveDietPlan(plan: DietPlan) async throws
    func updateOnboardingStep(step: OnboardingStep) async throws
    func trackEvent(event: LoggableEvent)
}

extension OnbInteractor: OnboardingDietPlanInteractor { }
