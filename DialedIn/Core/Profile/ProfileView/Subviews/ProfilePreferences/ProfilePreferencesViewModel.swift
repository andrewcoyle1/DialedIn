//
//  ProfilePreferencesViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfilePreferencesInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfilePreferencesInteractor { }

@MainActor
protocol ProfilePreferencesRouter {
    func showSettingsView()
    func showDevSettingsView()
}

extension CoreRouter: ProfilePreferencesRouter { }

@Observable
@MainActor
class ProfilePreferencesViewModel {
    private let interactor: ProfilePreferencesInteractor
    private let router: ProfilePreferencesRouter

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: ProfilePreferencesInteractor,
        router: ProfilePreferencesRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func formatUnitPreferences(length: LengthUnitPreference?, weight: WeightUnitPreference?) -> String {
        let lengthStr = length == .centimeters ? "Metric" : "Imperial"
        let weightStr = weight == .kilograms ? "Metric" : "Imperial"
        
        if lengthStr == weightStr {
            return lengthStr
        } else {
            return "Mixed"
        }
    }

    func navToSettingsView() {
        interactor.trackEvent(event: Event.navigate)
        router.showSettingsView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "ProfilePreferences_Navigate"
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
