//
//  OnboardingDateOfBirthPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingDateOfBirthPresenter {
    private let interactor: OnboardingDateOfBirthInteractor
    private let router: OnboardingDateOfBirthRouter

    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    init(
        interactor: OnboardingDateOfBirthInteractor,
        router: OnboardingDateOfBirthRouter
    ) {
        self.interactor = interactor
        self.router = router

    }
    
    func navigateToOnboardingHeight(userBuilder: UserModelBuilder) {
        var userModelbuilder = userBuilder
        userModelbuilder.setDateOfBirth(dateOfBirth)

        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingHeightView(delegate: OnboardingHeightDelegate(userModelBuilder: userModelbuilder))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "OnboardingGenderView_Navigate"
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
