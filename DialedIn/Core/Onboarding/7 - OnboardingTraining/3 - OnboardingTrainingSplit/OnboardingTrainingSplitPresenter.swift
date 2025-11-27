//
//  OnboardingTrainingSplitPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingSplitPresenter {
    private let interactor: OnboardingTrainingSplitInteractor
    private let router: OnboardingTrainingSplitRouter

    var selectedSplit: TrainingSplitType?

    init(
        interactor: OnboardingTrainingSplitInteractor,
        router: OnboardingTrainingSplitRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToSchedule(builder: TrainingProgramBuilder) {
        guard let split = selectedSplit else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setSplitType(split)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingScheduleView(delegate: OnboardingTrainingScheduleDelegate(trainingProgramBuilder: updatedBuilder))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingSplit_Navigate"
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
