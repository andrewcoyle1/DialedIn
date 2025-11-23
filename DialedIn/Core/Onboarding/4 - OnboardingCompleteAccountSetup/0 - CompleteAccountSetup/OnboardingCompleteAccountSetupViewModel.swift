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

@MainActor
protocol OnboardingCompleteAccountSetupRouter {
    func showDevSettingsView()
    func showOnboardingNamePhotoView()
}

extension CoreRouter: OnboardingCompleteAccountSetupRouter { }

@Observable
@MainActor
class OnboardingCompleteAccountSetupViewModel {
    private let interactor: OnboardingCompleteAccountSetupInteractor
    private let router: OnboardingCompleteAccountSetupRouter

    init(
        interactor: OnboardingCompleteAccountSetupInteractor,
        router: OnboardingCompleteAccountSetupRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func handleNavigation() {
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingNamePhotoView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "CompleteAccountSetup_Navigate"
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
