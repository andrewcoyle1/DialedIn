//
//  OnboardingCustomisingProgramPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingCustomisingProgramPresenter {
    private let interactor: OnboardingCustomisingProgramInteractor
    private let router: OnboardingCustomisingProgramRouter

    var isLoading: Bool = false

    init(
        interactor: OnboardingCustomisingProgramInteractor,
        router: OnboardingCustomisingProgramRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToTrainingExperience() {
        let builder = TrainingProgramBuilder()
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate(trainingProgramBuilder: builder))
    }
    
    func navigateToPreferredDiet() {
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingPreferredDietView()
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_CustProgram_Navigate"
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
