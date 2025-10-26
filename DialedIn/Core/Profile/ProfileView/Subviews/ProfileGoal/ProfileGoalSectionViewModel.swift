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
    
    init(
        interactor: ProfileGoalSectionInteractor
    ) {
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
}
