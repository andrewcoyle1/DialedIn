//
//  OnboardingTrainingSplitViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

protocol OnboardingTrainingSplitInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingSplitInteractor { }

@Observable
@MainActor
class OnboardingTrainingSplitViewModel {
    private let interactor: OnboardingTrainingSplitInteractor
    
    var selectedSplit: TrainingSplitType?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingTrainingSplitInteractor) {
        self.interactor = interactor
    }
    
    func navigateToSchedule(path: Binding<[OnboardingPathOption]>, builder: TrainingProgramBuilder) {
        guard let split = selectedSplit else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setSplitType(split)
        interactor.trackEvent(event: Event.navigate(destination: .trainingSchedule(trainingProgramBuilder: updatedBuilder)))
        path.wrappedValue.append(.trainingSchedule(trainingProgramBuilder: updatedBuilder))
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingSplit_Navigate"
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
