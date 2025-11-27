//
//  OnboardingProteinIntakeInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol OnboardingProteinIntakeInteractor {
    var currentUser: UserModel? { get }
    var currentTrainingPlan: TrainingPlan? { get }
    func get(id: String) -> ProgramTemplateModel?
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingProteinIntakeInteractor { }
