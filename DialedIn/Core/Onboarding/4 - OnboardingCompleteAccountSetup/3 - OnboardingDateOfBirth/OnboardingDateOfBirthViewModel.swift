//
//  OnboardingDateOfBirthViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingDateOfBirthInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingDateOfBirthInteractor { }

@Observable
@MainActor
class OnboardingDateOfBirthViewModel {
    private let interactor: OnboardingDateOfBirthInteractor
    
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingDateOfBirthInteractor) {
        self.interactor = interactor
    }
    
    func navigateToOnboardingHeight(path: Binding<[OnboardingPathOption]>, userBuilder: UserModelBuilder) {
        var builder = userBuilder
        builder.setDateOfBirth(dateOfBirth)
        
        interactor.trackEvent(event: Event.navigate(destination: .height(userModelBuilder: builder)))
        path.wrappedValue.append(.height(userModelBuilder: builder))
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
