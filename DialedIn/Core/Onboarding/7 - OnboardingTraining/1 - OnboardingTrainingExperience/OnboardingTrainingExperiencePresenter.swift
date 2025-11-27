//
//  OnboardingTrainingExperiencePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingExperiencePresenter {
    private let interactor: OnboardingTrainingExperienceInteractor
    private let router: OnboardingTrainingExperienceRouter

    var selectedLevel: DifficultyLevel?
        
    init(
        interactor: OnboardingTrainingExperienceInteractor,
        router: OnboardingTrainingExperienceRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToDaysPerWeek(builder: TrainingProgramBuilder) {
        guard let level = selectedLevel else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setExperienceLevel(level)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingDaysPerWeekView(delegate: OnboardingTrainingDaysPerWeekDelegate(trainingProgramBuilder: updatedBuilder))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingExperience_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
