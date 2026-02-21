//
//  OnboardingTrainingSchedulePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingSchedulePresenter {
    private let interactor: OnboardingTrainingScheduleInteractor
    private let router: OnboardingTrainingScheduleRouter

    var selectedDays: Set<Int> = []
        
    init(
        interactor: OnboardingTrainingScheduleInteractor,
        router: OnboardingTrainingScheduleRouter,
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToEquipment(delegate: OnboardingTrainingScheduleDelegate) {
        guard !selectedDays.isEmpty else { return }
        
        let delegate = OnboardingTrainingEquipmentDelegate(delegate: delegate, scheduledDays: selectedDays)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingEquipmentView(delegate: delegate)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingSchedule_Navigate"
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
