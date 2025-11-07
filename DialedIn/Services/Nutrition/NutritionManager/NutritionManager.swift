//
//  NutritionManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

extension CalorieFloor {
    var minimumValue: Double {
        switch self {
        case .standard: return 1200
        case .low: return 800
        }
    }
}

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

    func saveDietPlan(plan: DietPlan) async throws {
        try local.saveDietPlan(plan: plan)
        currentDietPlan = plan
        if let userId = plan.userId {
            try await remote.saveDietPlan(userId: userId, plan: plan)
        }
    }

    func createAndSaveDietPlan(user: UserModel?, builder: DietPlanBuilder) async throws {
        let plan = computeDietPlan(user: user, builder: builder)
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
    func computeDietPlan(user: UserModel?, builder: DietPlanBuilder) -> DietPlan {
        let now = Date()
        let userId = user?.userId
        let tdee = estimateTDEE(user: user)
        let minimumCalories = builder.calorieFloor?.minimumValue ?? CalorieFloor.standard.minimumValue
        let targetCalories = max(tdee, minimumCalories)
        
        let proteinGrams = calculateProteinGrams(user: user, proteinIntake: builder.proteinIntake ?? .moderate)
        let macroPercentages = calculateMacroPercentages(
            preferredDiet: builder.preferredDiet,
            targetCalories: targetCalories,
            proteinGrams: proteinGrams
        )
        
        let dailyCalories = calculateDailyCalories(
            targetCalories: targetCalories,
            minimumCalories: minimumCalories,
            calorieDistribution: builder.calorieDistribution ?? .even,
            trainingType: builder.trainingType ?? .cardioAndWeightlifting
        )
        
        let dailyMacros = computeDailyMacros(
            dailyCalories: dailyCalories,
            proteinGrams: proteinGrams,
            macroPercentages: macroPercentages
        )
        
        return DietPlan(
            planId: UUID().uuidString,
            userId: userId,
            createdAt: now,
            tdeeEstimate: round(tdee),
            preferredDiet: builder.preferredDiet.rawValue,
            calorieFloor: builder.calorieFloor?.rawValue ?? CalorieFloor.standard.rawValue,
            trainingType: builder.trainingType?.rawValue ?? TrainingType.cardioAndWeightlifting.rawValue,
            calorieDistribution: builder.calorieDistribution?.rawValue ?? CalorieDistribution.even.rawValue,
            proteinIntake: builder.proteinIntake?.rawValue ?? ProteinIntake.moderate.rawValue,
            days: dailyMacros
        )
    }
    
    private func calculateProteinGrams(user: UserModel?, proteinIntake: ProteinIntake) -> Double {
        let userKg = max(user?.weightKilograms ?? 70, 30)
        let proteinPerKg: Double
        switch proteinIntake {
        case .low: proteinPerKg = 1.6
        case .moderate: proteinPerKg = 2.0
        case .high: proteinPerKg = 2.2
        case .veryHigh: proteinPerKg = 2.6
        }
        return proteinPerKg * userKg
    }
    
    private func calculateMacroPercentages(
        preferredDiet: PreferredDiet,
        targetCalories: Double,
        proteinGrams: Double
    ) -> (fatPercent: Double, carbPercent: Double) {
        let proteinCalories = proteinGrams * 4
        let fatPercent: Double
        let carbPercent: Double
        
        switch preferredDiet {
        case .balanced:
            fatPercent = 0.30
            carbPercent = 1.0 - fatPercent - (proteinCalories / max(targetCalories, 1))
        case .lowFat:
            fatPercent = 0.20
            carbPercent = 1.0 - fatPercent - (proteinCalories / max(targetCalories, 1))
        case .lowCarb:
            carbPercent = 0.20
            fatPercent = 1.0 - carbPercent - (proteinCalories / max(targetCalories, 1))
        case .keto:
            carbPercent = 0.05
            fatPercent = 1.0 - carbPercent - (proteinCalories / max(targetCalories, 1))
        }
        
        return (fatPercent, carbPercent)
    }
    
    private func calculateDailyCalories(
        targetCalories: Double,
        minimumCalories: Double,
        calorieDistribution: CalorieDistribution,
        trainingType: TrainingType
    ) -> [Double] {
        guard calorieDistribution == .varied && trainingType != .noneOrRelaxedActivity else {
            return Array(repeating: max(targetCalories, minimumCalories), count: 7)
        }
        
        let high = targetCalories * 1.10
        let low = targetCalories * 0.925
        return [high, low, high, low, high, low, low].map { max($0, minimumCalories) }
    }
    
    private func computeDailyMacros(
        dailyCalories: [Double],
        proteinGrams: Double,
        macroPercentages: (fatPercent: Double, carbPercent: Double)
    ) -> [DailyMacroTarget] {
        let proteinCalories = proteinGrams * 4
        
        return dailyCalories.map { cals in
            let remainingCalories = max(cals - proteinCalories, 0)
            let fatCalories = max(remainingCalories * macroPercentages.fatPercent, 0)
            let carbCalories = max(remainingCalories - fatCalories, 0)
            let fatGrams = fatCalories / 9
            let carbGrams = carbCalories / 4
            return DailyMacroTarget(
                calories: round(cals),
                proteinGrams: round(proteinGrams),
                carbGrams: round(carbGrams),
                fatGrams: round(fatGrams)
            )
        }
    }

    // MARK: - Estimation
    func estimateTDEE(user: UserModel?) -> Double {
        let gender = user?.gender ?? .male
        let weightKg = max(user?.weightKilograms ?? 70, 30)
        let heightCm = max(user?.heightCentimeters ?? 175, 120)
        let ageYears = calculateAge(from: user?.dateOfBirth)
        
        let mifflinGenderCoefficient: Double = (gender == .male) ? 5 : -161
        let bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageYears)) + mifflinGenderCoefficient
        
        let activityMultiplier = calculateActivityMultiplier(
            dailyActivity: user?.dailyActivityLevel ?? .moderate,
            exerciseFrequency: user?.exerciseFrequency ?? .threeToFour
        )
        
        let tdee = bmr * activityMultiplier
        return max(1000, tdee)
    }
    
    private func calculateAge(from dateOfBirth: Date?) -> Int {
        guard let dob = dateOfBirth else { return 30 }
        let years = Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 30
        return max(14, years)
    }
    
    private func calculateActivityMultiplier(
        dailyActivity: ProfileDailyActivityLevel,
        exerciseFrequency: ProfileExerciseFrequency
    ) -> Double {
        let baseMultiplier: Double
        switch dailyActivity {
        case .sedentary: baseMultiplier = 1.2
        case .light: baseMultiplier = 1.35
        case .moderate: baseMultiplier = 1.5
        case .active: baseMultiplier = 1.7
        case .veryActive: baseMultiplier = 1.9
        }
        
        let exerciseAdj: Double
        switch exerciseFrequency {
        case .never: exerciseAdj = 0.0
        case .oneToTwo: exerciseAdj = 0.05
        case .threeToFour: exerciseAdj = 0.10
        case .fiveToSix: exerciseAdj = 0.15
        case .daily: exerciseAdj = 0.20
        }
        
        return baseMultiplier + exerciseAdj
    }
}
