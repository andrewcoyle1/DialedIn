//
//  OnboardingTrainingExperienceViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

protocol OnboardingTrainingExperienceInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingExperienceInteractor { }

@Observable
@MainActor
class OnboardingTrainingExperienceViewModel {
    private let interactor: OnboardingTrainingExperienceInteractor
    
    var selectedLevel: DifficultyLevel?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingTrainingExperienceInteractor) {
        self.interactor = interactor
    }
    
    func navigateToDaysPerWeek(path: Binding<[OnboardingPathOption]>, builder: TrainingProgramBuilder) {
        guard let level = selectedLevel else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setExperienceLevel(level)
        interactor.trackEvent(event: Event.navigate(destination: .trainingDaysPerWeek(trainingProgramBuilder: updatedBuilder)))
        path.wrappedValue.append(.trainingDaysPerWeek(trainingProgramBuilder: updatedBuilder))
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingExperience_Navigate"
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
