//
//  ProfileGoalSectionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileGoalSectionInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileGoalSectionInteractor { }

@Observable
@MainActor
class ProfileGoalSectionViewModel {
    private let interactor: ProfileGoalSectionInteractor

    var showSetGoalSheet: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var currentGoal: WeightGoal? {
        interactor.currentGoal
    }
    
    init(interactor: ProfileGoalSectionInteractor) {
        self.interactor = interactor
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

    func navToProfileGoals(path: Binding<[TabBarPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .profileGoals))
        path.wrappedValue.append(.profileGoals)
    }

    enum Event: LoggableEvent {
        case navigate(destination: TabBarPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "ProfileGoalSection_Navigate"
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
