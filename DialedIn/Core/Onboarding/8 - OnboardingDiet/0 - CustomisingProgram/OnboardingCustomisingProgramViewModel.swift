//
//  OnboardingCustomisingProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCustomisingProgramInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCustomisingProgramInteractor { }

@Observable
@MainActor
class OnboardingCustomisingProgramViewModel {
    private let interactor: OnboardingCustomisingProgramInteractor
    
    var showAlert: AnyAppAlert?
    var isLoading: Bool = false

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingCustomisingProgramInteractor
    ) {
        self.interactor = interactor
    }
    
    func navigateToTrainingExperience(path: Binding<[OnboardingPathOption]>) {
        let builder = TrainingProgramBuilder()
        interactor.trackEvent(event: Event.navigate(destination: .trainingExperience(trainingProgramBuilder: builder)))
        path.wrappedValue.append(.trainingExperience(trainingProgramBuilder: builder))
    }
    
    func navigateToPreferredDiet(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .preferredDiet))
        path.wrappedValue.append(.preferredDiet)
    }
    
    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "Onboarding_CustProgram_Navigate"
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
