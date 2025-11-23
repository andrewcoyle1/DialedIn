//
//  OnboardingTrainingEquipmentViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

protocol OnboardingTrainingEquipmentInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingEquipmentInteractor { }

@MainActor
protocol OnboardingTrainingEquipmentRouter {
    func showDevSettingsView()
    func showOnboardingTrainingReviewView(delegate: OnboardingTrainingReviewViewDelegate)
}

extension CoreRouter: OnboardingTrainingEquipmentRouter { }

@Observable
@MainActor
class OnboardingTrainingEquipmentViewModel {
    private let interactor: OnboardingTrainingEquipmentInteractor
    private let router: OnboardingTrainingEquipmentRouter

    var selectedEquipment: Set<EquipmentType> = []
    
    init(
        interactor: OnboardingTrainingEquipmentInteractor,
        router: OnboardingTrainingEquipmentRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToReview(builder: TrainingProgramBuilder) {
        guard !selectedEquipment.isEmpty else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setAvailableEquipment(selectedEquipment)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingReviewView(delegate: OnboardingTrainingReviewViewDelegate(trainingProgramBuilder: updatedBuilder))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingEquipment_Navigate"
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
