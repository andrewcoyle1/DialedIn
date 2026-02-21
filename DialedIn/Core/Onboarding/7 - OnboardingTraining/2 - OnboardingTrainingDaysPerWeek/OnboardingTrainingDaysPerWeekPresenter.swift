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
    
    func navigateToSplit(delegate: OnboardingTrainingDaysPerWeekDelegate) {
        guard let days = selectedDays else { return }
        
        let delegate = OnboardingTrainingSplitDelegate(delegate: delegate, selectedDays: days)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingSplitView(delegate: delegate)
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
