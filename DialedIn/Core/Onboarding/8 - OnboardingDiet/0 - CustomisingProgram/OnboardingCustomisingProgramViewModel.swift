//
//  OnboardingCustomisingProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCustomisingProgramInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCustomisingProgramInteractor { }

@MainActor
protocol OnboardingCustomisingProgramRouter {
    func showDevSettingsView()
    func showOnboardingPreferredDietView()
    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceViewDelegate)
}

extension CoreRouter: OnboardingCustomisingProgramRouter { }

@Observable
@MainActor
class OnboardingCustomisingProgramViewModel {
    private let interactor: OnboardingCustomisingProgramInteractor
    private let router: OnboardingCustomisingProgramRouter

    var showAlert: AnyAppAlert?
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
        router.showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceViewDelegate(trainingProgramBuilder: builder))
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
