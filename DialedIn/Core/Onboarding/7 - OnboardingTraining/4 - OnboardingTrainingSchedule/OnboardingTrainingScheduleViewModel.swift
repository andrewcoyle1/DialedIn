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

@Observable
@MainActor
class OnboardingTrainingScheduleViewModel {
    private let interactor: OnboardingTrainingScheduleInteractor
    
    var selectedDays: Set<Int> = []
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingTrainingScheduleInteractor, builder: TrainingProgramBuilder? = nil) {
        self.interactor = interactor
        if let builder = builder, !builder.weeklySchedule.isEmpty {
            selectedDays = builder.weeklySchedule
        }
    }
    
    func navigateToEquipment(path: Binding<[OnboardingPathOption]>, builder: TrainingProgramBuilder) {
        guard !selectedDays.isEmpty else { return }
        
        var updatedBuilder = builder
        updatedBuilder.setWeeklySchedule(selectedDays)
        interactor.trackEvent(event: Event.navigate(destination: .trainingEquipment(trainingProgramBuilder: updatedBuilder)))
        path.wrappedValue.append(.trainingEquipment(trainingProgramBuilder: updatedBuilder))
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_TrainingSchedule_Navigate"
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
