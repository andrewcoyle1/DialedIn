//
//  GenderPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class GenderPresenter {
    private let interactor: GenderInteractor
    private let router: GenderRouter

    var selectedGender: Gender?
    
    var canSubmit: Bool {
        selectedGender != nil
    }
    
    init(
        interactor: GenderInteractor,
        router: GenderRouter
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

    func onContinuePressed() {
        if let gender = selectedGender {
            let delegate = DateOfBirthDelegate(gender: gender)
            interactor.trackEvent(event: Event.navigate)
            router.showDateOfBirthView(delegate: delegate)
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
            case .navigate: return "GenderView_Navigate"
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
