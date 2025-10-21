//
//  ProfileGoalSectionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileGoalSectionViewModel {
    private let userManager: UserManager
    private let goalManager: GoalManager

    var showSetGoalSheet: Bool = false

    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var currentGoal: WeightGoal? {
        goalManager.currentGoal
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
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
