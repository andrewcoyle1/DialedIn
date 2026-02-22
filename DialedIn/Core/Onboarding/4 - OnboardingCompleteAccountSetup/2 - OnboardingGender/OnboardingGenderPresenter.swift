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
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
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
        case onAppear
        case onDisappear
        case navigate

        var eventName: String {
            switch self {
            case .onAppear:             return "AppView_Appear"
            case .onDisappear:          return "AppView_Disappear"
            case .navigate: return "OnboardingGenderView_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            default:
                return .analytic
            }
        }
    }
}
