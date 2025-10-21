//
//  ProfileGoalsDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileGoalsDetailViewModel {
    private let userManager: UserManager
    private let userWeightManager: UserWeightManager
    private let goalManager: GoalManager
    
    private(set) var realWeightHistory: [WeightEntry] = []
    var showLogWeightSheet: Bool = false

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
        self.userWeightManager = container.resolve(UserWeightManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
    }
    
    func getActiveGoal() async {
        if let user = currentUser {
            // Load active goal
            _ = try? await goalManager.getActiveGoal(userId: user.userId)
            // Load weight history
            realWeightHistory = (try? await userWeightManager.getWeightHistory(userId: user.userId, limit: 10)) ?? []
        }
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
    
    func objectiveIcon(_ objective: String) -> String {
        if objective.lowercased().contains("lose") {
            return "arrow.down.circle.fill"
        } else if objective.lowercased().contains("gain") {
            return "arrow.up.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }
    
    func objectiveDescription(_ objective: String) -> String {
        if objective.lowercased().contains("lose") {
            return "Your goal is to lose weight in a healthy and sustainable way. We'll help you achieve this through personalized nutrition and training guidance."
        } else if objective.lowercased().contains("gain") {
            return "Your goal is to gain weight through muscle building and proper nutrition. We'll support you with customized plans to help you reach your target."
        } else {
            return "Your goal is to maintain your current weight while staying healthy and fit. We'll help you maintain balance through proper nutrition and exercise."
        }
    }
    
    func motivationalMessage(_ objective: String) -> String {
        if objective.lowercased().contains("lose") {
            return "Every step you take towards your goal is progress. Stay consistent with your nutrition and exercise, and you'll reach your target weight. Remember, sustainable changes lead to lasting results."
        } else if objective.lowercased().contains("gain") {
            return "Building healthy weight takes time and dedication. Focus on nutrient-dense foods and progressive strength training. Your body will thank you for the consistent effort."
        } else {
            return "Maintaining your current weight is a fantastic goal! Focus on balanced nutrition and regular activity to keep your body healthy and strong. Consistency is key to long-term success."
        }
    }
}
