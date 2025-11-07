//
//  OnboardingTrainingDaysPerWeekViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

protocol OnboardingTrainingDaysPerWeekInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingDaysPerWeekInteractor { }

@Observable
@MainActor
class OnboardingTrainingDaysPerWeekViewModel {
    private let interactor: OnboardingTrainingDaysPerWeekInteractor
    
    var selectedDays: Int?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingTrainingDaysPerWeekInteractor) {
        self.interactor = interactor
    }
    
    func navigateToSplit(path: Binding<[OnboardingPathOption]>, builder: TrainingProgramBuilder) {
        guard let days = selectedDays else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setTargetDaysPerWeek(days)
        interactor.trackEvent(event: Event.navigate(destination: .trainingSplit(trainingProgramBuilder: updatedBuilder)))
        path.wrappedValue.append(.trainingSplit(trainingProgramBuilder: updatedBuilder))
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingDaysPerWeek_Navigate"
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
