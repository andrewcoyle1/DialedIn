//
//  OnboardingCustomisingProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingTrainingProgramInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingProgramInteractor { }

@MainActor
protocol OnboardingTrainingProgramRouter {
    func showDevSettingsView()
    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceViewDelegate)
}

extension CoreRouter: OnboardingTrainingProgramRouter { }

@Observable
@MainActor
class OnboardingTrainingProgramViewModel {
    private let interactor: OnboardingTrainingProgramInteractor
    private let router: OnboardingTrainingProgramRouter

    var showAlert: AnyAppAlert?
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
        router.showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceViewDelegate(trainingProgramBuilder: builder))
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
