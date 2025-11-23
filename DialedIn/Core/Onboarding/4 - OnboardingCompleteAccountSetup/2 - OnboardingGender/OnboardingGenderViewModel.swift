//
//  OnboardingGenderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingGenderInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingGenderInteractor { }

@MainActor
protocol OnboardingGenderRouter {
    func showDevSettingsView()
    func showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthViewDelegate)
}

extension CoreRouter: OnboardingGenderRouter { }

@Observable
@MainActor
class OnboardingGenderViewModel {
    private let interactor: OnboardingGenderInteractor
    private let router: OnboardingGenderRouter

    var selectedGender: Gender?
    
    var canSubmit: Bool {
        selectedGender != nil
    }
    
    init(
        interactor: OnboardingGenderInteractor,
        router: OnboardingGenderRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToDateOfBirth() {
        if let gender = selectedGender {
            let userBuilder = UserModelBuilder(gender: gender)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthViewDelegate(userModelBuilder: userBuilder))
        }
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
