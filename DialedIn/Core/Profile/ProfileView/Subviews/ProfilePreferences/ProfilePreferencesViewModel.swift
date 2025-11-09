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

@Observable
@MainActor
class ProfilePreferencesViewModel {
    private let interactor: ProfilePreferencesInteractor
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: ProfilePreferencesInteractor
    ) {
        self.interactor = interactor
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

    func navToSettingsView(path: Binding<[TabBarPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .settingsView))
        path.wrappedValue.append(.settingsView)
    }

    enum Event: LoggableEvent {
        case navigate(destination: TabBarPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "ProfilePreferences_Navigate"
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
