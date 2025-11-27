//
//  ProfileGoalSectionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileGoalSectionPresenter {
    private let interactor: ProfileGoalSectionInteractor
    private let router: ProfileGoalSectionRouter

    var showSetGoalSheet: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var currentGoal: WeightGoal? {
        interactor.currentGoal
    }
    
    init(
        interactor: ProfileGoalSectionInteractor,
        router: ProfileGoalSectionRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func formatWeight(_ weightKg: Double, unit: WeightUnitPreference) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }

    func navToProfileGoals() {
        interactor.trackEvent(event: Event.navigate)
        router.showProfileGoalsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "ProfileGoalSection_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default: return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
