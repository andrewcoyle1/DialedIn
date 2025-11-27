//
//  OnboardingGenderPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingGenderPresenter {
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
            router.showOnboardingDateOfBirthView(delegate: OnboardingDateOfBirthDelegate(userModelBuilder: userBuilder))
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
