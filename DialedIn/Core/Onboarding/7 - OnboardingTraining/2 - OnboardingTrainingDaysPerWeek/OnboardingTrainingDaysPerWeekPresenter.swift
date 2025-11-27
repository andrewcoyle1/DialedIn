//
//  OnboardingTrainingDaysPerWeekPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingDaysPerWeekPresenter {
    private let interactor: OnboardingTrainingDaysPerWeekInteractor
    private let router: OnboardingTrainingDaysPerWeekRouter

    var selectedDays: Int?

    init(
        interactor: OnboardingTrainingDaysPerWeekInteractor,
        router: OnboardingTrainingDaysPerWeekRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToSplit(builder: TrainingProgramBuilder) {
        guard let days = selectedDays else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setTargetDaysPerWeek(days)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingSplitView(delegate: OnboardingTrainingSplitDelegate(trainingProgramBuilder: updatedBuilder))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingDaysPerWeek_Navigate"
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
