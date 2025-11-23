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

@MainActor
protocol OnboardingDateOfBirthRouter {
    func showDevSettingsView()
    func showOnboardingHeightView(delegate: OnboardingHeightViewDelegate)
}

extension CoreRouter: OnboardingDateOfBirthRouter { }

@Observable
@MainActor
class OnboardingDateOfBirthViewModel {
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
        router.showOnboardingHeightView(delegate: OnboardingHeightViewDelegate(userModelBuilder: userModelbuilder))
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
