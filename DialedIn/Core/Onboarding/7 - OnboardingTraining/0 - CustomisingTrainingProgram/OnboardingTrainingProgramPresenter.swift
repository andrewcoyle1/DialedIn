//
//  OnboardingCustomisingProgramPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingProgramPresenter {
    private let interactor: OnboardingTrainingProgramInteractor
    private let router: OnboardingTrainingProgramRouter

    var isLoading: Bool = false

    init(
        interactor: OnboardingTrainingProgramInteractor,
        router: OnboardingTrainingProgramRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToTrainingExperience() {
        let builder = TrainingProgramBuilder()
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate(trainingProgramBuilder: builder))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_CustTrainProgram_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default: return nil
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
