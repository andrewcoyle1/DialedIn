//
//  OnboardingIntroViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingIntroInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingIntroInteractor { }

protocol OnboardingIntroRouter {
    func showDevSettingsView()
}

extension CoreRouter: OnboardingIntroRouter { }

@Observable
@MainActor
class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroInteractor
    private let router: OnboardingIntroRouter

    init(
        interactor: OnboardingIntroInteractor,
        router: OnboardingIntroRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToAuthOptions(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .authOptions))
        path.wrappedValue.append(.authOptions)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate:    return "IntroView_Navigate"
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
