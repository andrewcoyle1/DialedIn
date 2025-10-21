//
//  ProfileViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileViewModel {
    private let userManager: UserManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let programTemplateManager: ProgramTemplateManager
    private let ingredientTemplateManager: IngredientTemplateManager
    private let recipeTemplateManager: RecipeTemplateManager
    private let nutritionManager: NutritionManager
    private let logManager: LogManager
    private let goalManager: GoalManager
    
    private(set) var activeGoal: WeightGoal?
    
#if DEBUG || MOCK
    var showDebugView: Bool = false
#endif
    var showNotifications: Bool = false
    var showCreateProfileSheet: Bool = false
    var showSetGoalSheet: Bool = false
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var currentGoal: WeightGoal? {
        goalManager.currentGoal
    }
    
    var currentDietPlan: DietPlan? {
        nutritionManager.currentDietPlan
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
        self.ingredientTemplateManager = container.resolve(IngredientTemplateManager.self)!
        self.recipeTemplateManager = container.resolve(RecipeTemplateManager.self)!
        self.nutritionManager = container.resolve(NutritionManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.goalManager = container.resolve(GoalManager.self)!
    }
    
    func getActiveGoal() async {
        if let userId = self.currentUser?.userId {
            activeGoal = try? await goalManager.getActiveGoal(userId: userId)
        }
    }
    
//    func formatHeight(_ heightCm: Double, unit: LengthUnitPreference) -> String {
//        switch unit {
//        case .centimeters:
//            return String(format: "%.0f cm", heightCm)
//        case .inches:
//            let totalInches = heightCm / 2.54
//            let feet = Int(totalInches / 12)
//            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
//            return "\(feet)' \(inches)\""
//        }
//    }
    
//    func formatWeight(_ weightKg: Double, unit: WeightUnitPreference) -> String {
//        switch unit {
//        case .kilograms:
//            return String(format: "%.1f kg", weightKg)
//        case .pounds:
//            let pounds = weightKg * 2.20462
//            return String(format: "%.1f lbs", pounds)
//        }
//    }
    
//    func calculateBMI(heightCm: Double, weightKg: Double) -> Double {
//        let heightM = heightCm / 100
//        return weightKg / (heightM * heightM)
//    }
    
//    func formatExerciseFrequency(_ frequency: ProfileExerciseFrequency) -> String {
//        switch frequency {
//        case .never: return "Never"
//        case .oneToTwo: return "1-2 times/week"
//        case .threeToFour: return "3-4 times/week"
//        case .fiveToSix: return "5-6 times/week"
//        case .daily: return "Daily"
//        }
//    }
    
//    func formatActivityLevel(_ level: ProfileDailyActivityLevel) -> String {
//        switch level {
//        case .sedentary: return "Sedentary"
//        case .light: return "Light"
//        case .moderate: return "Moderate"
//        case .active: return "Active"
//        case .veryActive: return "Very Active"
//        }
//    }
    
//    func formatCardioFitness(_ level: ProfileCardioFitnessLevel) -> String {
//        switch level {
//        case .beginner: return "Beginner"
//        case .novice: return "Novice"
//        case .intermediate: return "Intermediate"
//        case .advanced: return "Advanced"
//        case .elite: return "Elite"
//        }
//    }
    
//    func formatUnitPreferences(length: LengthUnitPreference?, weight: WeightUnitPreference?) -> String {
//        let lengthStr = length == .centimeters ? "Metric" : "Imperial"
//        let weightStr = weight == .kilograms ? "Metric" : "Imperial"
//        
//        if lengthStr == weightStr {
//            return lengthStr
//        } else {
//            return "Mixed"
//        }
//    }
}
