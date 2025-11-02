//
//  OnboardingGenderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingGenderInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingGenderInteractor { }

@Observable
@MainActor
class OnboardingGenderViewModel {
    private let interactor: OnboardingGenderInteractor
    
    var selectedGender: Gender?

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var canSubmit: Bool {
        selectedGender != nil
    }
    
    init(interactor: OnboardingGenderInteractor) {
        self.interactor = interactor
    }
    
    func navigateToDateOfBirth(path: Binding<[OnboardingPathOption]>) {
        if let gender = selectedGender {
            let userBuilder = UserModelBuilder(gender: gender)
            interactor.trackEvent(event: Event.navigate(destination: .dateOfBirth(userModelBuilder: userBuilder)))
            path.wrappedValue.append(.dateOfBirth(userModelBuilder: userBuilder))
        }
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingGenderView_Navigate"
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
