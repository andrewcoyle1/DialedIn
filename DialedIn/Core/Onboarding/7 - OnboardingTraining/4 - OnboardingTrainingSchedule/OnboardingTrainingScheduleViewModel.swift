//
//  OnboardingTrainingScheduleViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

protocol OnboardingTrainingScheduleInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingScheduleInteractor { }

@MainActor
protocol OnboardingTrainingScheduleRouter {
    func showDevSettingsView()
    func showOnboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentViewDelegate)
}

extension CoreRouter: OnboardingTrainingScheduleRouter { }

@Observable
@MainActor
class OnboardingTrainingScheduleViewModel {
    private let interactor: OnboardingTrainingScheduleInteractor
    private let router: OnboardingTrainingScheduleRouter

    var selectedDays: Set<Int> = []
        
    init(
        interactor: OnboardingTrainingScheduleInteractor,
        router: OnboardingTrainingScheduleRouter,
        builder: TrainingProgramBuilder? = nil
    ) {
        self.interactor = interactor
        self.router = router
        if let builder = builder, !builder.weeklySchedule.isEmpty {
            selectedDays = builder.weeklySchedule
        }
    }
    
    func navigateToEquipment(builder: TrainingProgramBuilder) {
        guard !selectedDays.isEmpty else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setWeeklySchedule(selectedDays)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentViewDelegate(trainingProgramBuilder: updatedBuilder))
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
