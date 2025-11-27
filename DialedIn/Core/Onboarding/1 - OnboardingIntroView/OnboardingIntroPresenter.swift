//
//  OnboardingIntroPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingIntroPresenter {
    private let interactor: OnboardingIntroInteractor
    private let router: OnboardingIntroRouter

    init(
        interactor: OnboardingIntroInteractor,
        router: OnboardingIntroRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToAuthOptions() {
        interactor.trackEvent(event: Event.navigate)
        router.showAuthOptionsView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate:    return "IntroView_Navigate"
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
