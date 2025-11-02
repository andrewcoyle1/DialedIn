//
//  OnboardingCompleteAccountSetupViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCompleteAccountSetupInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCompleteAccountSetupInteractor { }

@Observable
@MainActor
class OnboardingCompleteAccountSetupViewModel {
    private let interactor: OnboardingCompleteAccountSetupInteractor
        
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingCompleteAccountSetupInteractor) {
        self.interactor = interactor
    }
    
    func handleNavigation(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .namePhoto))
        path.wrappedValue.append(.namePhoto)
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "CompleteAccountSetup_Navigate"
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
