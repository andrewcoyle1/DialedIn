//
//  NutritionManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

@MainActor
@Observable
class NutritionManager {
    
    private let local: LocalNutritionPersistence
    private let remote: RemoteNutritionService
    private(set) var currentDietPlan: DietPlan?
    
    init(services: NutritionServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentDietPlan = local.getCurrentDietPlan()
    }

    // MARK: - Public API
    func createAndSaveDietPlan(
        user: UserModel?,
        preferredDiet: PreferredDiet,
        calorieFloor: CalorieFloor,
        trainingType: TrainingType,
        calorieDistribution: CalorieDistribution,
        proteinIntake: ProteinIntake
    ) async throws {
        let plan = try await computeDietPlan(
            user: user,
            preferredDiet: preferredDiet,
            calorieFloor: calorieFloor,
            trainingType: trainingType,
            calorieDistribution: calorieDistribution,
            proteinIntake: proteinIntake
        )
        try local.saveDietPlan(plan: plan)
        currentDietPlan = plan
        if let userId = plan.userId {
            try await remote.saveDietPlan(userId: userId, plan: plan)
        }
    }
    
    /// Get daily macro target for a specific date from the current diet plan
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget? {
        guard let plan = currentDietPlan else {
            return nil
        }
        
        // Calculate day of week (Monday = 0, Sunday = 6)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date) // Sunday = 1
        let dayIndex = (weekday + 5) % 7 // Convert to Monday = 0
        
        // Return the corresponding day's target from the 7-day plan
        guard dayIndex < plan.days.count else {
            return nil
        }
        
        return plan.days[dayIndex]
    }

    // MARK: - Core logic
    private func computeDietPlan(
        user: UserModel?,
        preferredDiet: PreferredDiet,
        calorieFloor: CalorieFloor,
        trainingType: TrainingType,
        calorieDistribution: CalorieDistribution,
        proteinIntake: ProteinIntake
    ) async throws -> DietPlan {
        let now = Date()
        let userId = user?.userId
        let tdee = estimateTDEE(user: user)

        // For v1, assume maintenance calories (objective not yet locally available)
        let minimumCalories: Double = {
            switch calorieFloor {
            case .standard: return 1200
            case .low: return 800
            }
        }()
        let targetCalories = max(tdee, minimumCalories)

        // Protein grams per kg based on selection
        let userKg = max(user?.weightKilograms ?? 70, 30)
        let proteinPerKg: Double
        switch proteinIntake {
        case .low: proteinPerKg = 1.6
        case .moderate: proteinPerKg = 2.0
        case .high: proteinPerKg = 2.2
        case .veryHigh: proteinPerKg = 2.6
        }
        let proteinGrams = proteinPerKg * userKg
        let proteinCalories = proteinGrams * 4

        // Set fat and carb percentages based on preferred diet
        let fatPercent: Double
        let carbPercent: Double
        switch preferredDiet {
        case .balanced:
            fatPercent = 0.30; carbPercent = 1.0 - fatPercent - (proteinCalories / max(targetCalories, 1))
        case .lowFat:
            fatPercent = 0.20; carbPercent = 1.0 - fatPercent - (proteinCalories / max(targetCalories, 1))
        case .lowCarb:
            carbPercent = 0.20; fatPercent = 1.0 - carbPercent - (proteinCalories / max(targetCalories, 1))
        case .keto:
            carbPercent = 0.05; fatPercent = 1.0 - carbPercent - (proteinCalories / max(targetCalories, 1))
        }

        // Distribute calories by day if varied and training is present
        let dailyCalories: [Double]
        if calorieDistribution == .varied && trainingType != .noneOrRelaxedActivity {
            // Simple pattern: higher calories on 3 training days (+10%), lower on 4 rest days (-7.5%) to keep weekly avg ~target
            let high = targetCalories * 1.10
            let low = targetCalories * 0.925
            dailyCalories = [high, low, high, low, high, low, low].map { max($0, minimumCalories) }
        } else {
            dailyCalories = Array(repeating: max(targetCalories, minimumCalories), count: 7)
        }

        // Compute daily macros
        let dailyMacros: [DailyMacroTarget] = dailyCalories.map { cals in
            let remainingCalories = max(cals - proteinCalories, 0)
            let fatCalories = max(remainingCalories * fatPercent, 0)
            let carbCalories = max(remainingCalories - fatCalories, 0)
            let fatGrams = fatCalories / 9
            let carbGrams = carbCalories / 4
            return DailyMacroTarget(calories: round(cals), proteinGrams: round(proteinGrams), carbGrams: round(carbGrams), fatGrams: round(fatGrams))
        }

        return DietPlan(
            planId: UUID().uuidString,
            userId: userId,
            createdAt: now,
            tdeeEstimate: round(tdee),
            preferredDiet: preferredDiet.rawValue,
            calorieFloor: calorieFloor.rawValue,
            trainingType: trainingType.rawValue,
            calorieDistribution: calorieDistribution.rawValue,
            proteinIntake: proteinIntake.rawValue,
            days: dailyMacros
        )
    }

    // MARK: - Estimation
    func estimateTDEE(user: UserModel?) -> Double {
        // Defaults if user data missing
        let gender = user?.gender ?? .male
        let weightKg = max(user?.weightKilograms ?? 70, 30)
        let heightCm = max(user?.heightCentimeters ?? 175, 120)
        let ageYears: Int = {
            guard let dob = user?.dateOfBirth else { return 30 }
            let years = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 30
            return max(14, years)
        }()
        // Mifflin-St Jeor BMR
        let mifflinGenderCoefficient: Double = (gender == .male) ? 5 : -161
        let bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageYears)) + mifflinGenderCoefficient

        // Activity multiplier
        let activity = user?.dailyActivityLevel ?? .moderate
        let exercise = user?.exerciseFrequency ?? .threeToFour
        let baseMultiplier: Double
        switch activity {
        case .sedentary: baseMultiplier = 1.2
        case .light: baseMultiplier = 1.35
        case .moderate: baseMultiplier = 1.5
        case .active: baseMultiplier = 1.7
        case .veryActive: baseMultiplier = 1.9
        }
        let exerciseAdj: Double
        switch exercise {
        case .never: exerciseAdj = 0.0
        case .oneToTwo: exerciseAdj = 0.05
        case .threeToFour: exerciseAdj = 0.10
        case .fiveToSix: exerciseAdj = 0.15
        case .daily: exerciseAdj = 0.20
        }
        let tdee = bmr * (baseMultiplier + exerciseAdj)
        return max(1000, tdee)
    }
}
