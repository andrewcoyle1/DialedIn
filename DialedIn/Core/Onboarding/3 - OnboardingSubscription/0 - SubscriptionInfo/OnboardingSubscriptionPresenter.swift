//
//  OnboardingSubscriptionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingSubscriptionPresenter {
    private let interactor: OnboardingSubscriptionInteractor
    private let router: OnboardingSubscriptionRouter

    init(
        interactor: OnboardingSubscriptionInteractor,
        router: OnboardingSubscriptionRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToSubscriptionPlan() {
        interactor.trackEvent(event: Event.navigate)
        router.showSubscriptionPlanView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "SubscriptionInfoView_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
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
