//
//  SubscriptionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class SubscriptionPresenter {
    private let interactor: SubscriptionInteractor
    private let router: SubscriptionRouter

    init(
        interactor: SubscriptionInteractor,
        router: SubscriptionRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToSubscriptionPlan() {
        interactor.trackEvent(event: Event.navigate)
        router.showPaywall(onPurchaseSuccess: { [weak self] in
            self?.router.showCompleteAccountSetupView()
        })
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
