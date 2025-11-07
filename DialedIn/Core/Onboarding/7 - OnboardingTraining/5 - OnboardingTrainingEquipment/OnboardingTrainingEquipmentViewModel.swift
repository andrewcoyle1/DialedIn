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

@Observable
@MainActor
class OnboardingTrainingEquipmentViewModel {
    private let interactor: OnboardingTrainingEquipmentInteractor
    
    var selectedEquipment: Set<EquipmentType> = []
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingTrainingEquipmentInteractor, builder: TrainingProgramBuilder? = nil) {
        self.interactor = interactor
        if let builder = builder, !builder.availableEquipment.isEmpty {
            selectedEquipment = builder.availableEquipment
        }
    }
    
    func navigateToReview(path: Binding<[OnboardingPathOption]>, builder: TrainingProgramBuilder) {
        guard !selectedEquipment.isEmpty else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setAvailableEquipment(selectedEquipment)
        interactor.trackEvent(event: Event.navigate(destination: .trainingReview(trainingProgramBuilder: updatedBuilder)))
        path.wrappedValue.append(.trainingReview(trainingProgramBuilder: updatedBuilder))
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingEquipment_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
