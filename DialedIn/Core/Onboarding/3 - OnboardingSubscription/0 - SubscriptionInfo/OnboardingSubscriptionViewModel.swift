//
//  OnboardingSubscriptionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingSubscriptionInteractor {
    func trackEvent(event: LoggableEvent) 
}

extension CoreInteractor: OnboardingSubscriptionInteractor { }

@Observable
@MainActor
class OnboardingSubscriptionViewModel {
    private let interactor: OnboardingSubscriptionInteractor
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingSubscriptionInteractor) {
        self.interactor = interactor
    }
    
    func navigateToSubscriptionPlan(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .subscriptionPlan))
        path.wrappedValue.append(.subscriptionPlan)
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "SubscriptionInfoView_Navigate"
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
