//
//  OnboardingCustomisingProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingTrainingProgramInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingProgramInteractor { }

@Observable
@MainActor
class OnboardingTrainingProgramViewModel {
    private let interactor: OnboardingTrainingProgramInteractor

    var showAlert: AnyAppAlert?
    var isLoading: Bool = false

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingTrainingProgramInteractor
    ) {
        self.interactor = interactor
    }
    
    func navigateToTrainingExperience(path: Binding<[OnboardingPathOption]>) {
        let builder = TrainingProgramBuilder()
        interactor.trackEvent(event: Event.navigate(destination: .trainingExperience(trainingProgramBuilder: builder)))
        path.wrappedValue.append(.trainingExperience(trainingProgramBuilder: builder))
    }
    
    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_CustTrainProgram_Navigate"
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
