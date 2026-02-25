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
@MainActor
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

    func createAndSaveDietPlan(user: UserModel?, delegate: DietPlanDelegate, trainingProgram: TrainingProgram? = nil) async throws {
        let plan = computeDietPlan(user: user, delegate: delegate, trainingProgram: trainingProgram)
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
    func computeDietPlan(user: UserModel?, delegate: DietPlanDelegate, trainingProgram: TrainingProgram? = nil) -> DietPlan {
        let now = Date()
        let userId = user?.userId
        let tdee = estimateTDEE(user: user)
        let minimumCalories = delegate.calorieFloor.minimumValue
        let targetCalories = max(tdee, minimumCalories)

        let proteinGrams = calculateProteinGrams(user: user, proteinIntake: delegate.proteinIntake)
        let macroPercentages = calculateMacroPercentages(
            preferredDiet: delegate.preferredDiet,
            targetCalories: targetCalories,
            proteinGrams: proteinGrams
        )

        // Derive training context from the user's active training program.
        // A day plan with at least one exercise counts as a training day.
        let trainingDaysPerWeek = trainingProgram?.dayPlans.filter { !$0.exercises.isEmpty }.count ?? 0
        let hasTraining = trainingDaysPerWeek > 0

        let dailyCalories = calculateDailyCalories(
            targetCalories: targetCalories,
            minimumCalories: minimumCalories,
            calorieDistribution: delegate.calorieDistribution,
            hasTraining: hasTraining
        )

        let dailyMacros = computeDailyMacros(
            dailyCalories: dailyCalories,
            proteinGrams: proteinGrams,
            macroPercentages: macroPercentages
        )

        let trainingTypeDescription = trainingProgram?.name ?? trainingFocusDescription(
            exerciseFrequency: user?.submittedExerciseFrequency
        )

        return DietPlan(
            planId: UUID().uuidString,
            userId: userId,
            createdAt: now,
            tdeeEstimate: round(tdee),
            preferredDiet: delegate.preferredDiet.rawValue,
            calorieFloor: delegate.calorieFloor.rawValue,
            trainingType: trainingTypeDescription,
            calorieDistribution: delegate.calorieDistribution.rawValue,
            proteinIntake: delegate.proteinIntake.rawValue,
            days: dailyMacros
        )
    }

    private func trainingFocusDescription(exerciseFrequency: ExerciseFrequency?) -> String {
        switch exerciseFrequency ?? .threeToFour {
        case .never: return "none"
        case .oneToTwo: return "light"
        case .threeToFour: return "moderate"
        case .fiveToSix: return "frequent"
        case .daily: return "daily"
        }
    }

    private func calculateProteinGrams(user: UserModel?, proteinIntake: ProteinIntake) -> Double {
        let userKg = max(user?.submittedWeightKilograms ?? 70, 30)
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

    /// Generates 7 daily calorie targets (Mon–Sun).
    /// When `calorieDistribution == .varied` and the user has training days,
    /// higher calories are assigned to training days (days 1, 3, 5) and lower to rest days.
    private func calculateDailyCalories(
        targetCalories: Double,
        minimumCalories: Double,
        calorieDistribution: CalorieDistribution,
        hasTraining: Bool
    ) -> [Double] {
        guard calorieDistribution == .varied && hasTraining else {
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
        let gender = user?.submittedGender ?? .male
        let weightKg = max(user?.submittedWeightKilograms ?? 70, 30)
        let heightCm = max(user?.submittedHeightCentimeters ?? 175, 120)
        let ageYears = calculateAge(from: user?.submittedDateOfBirth)

        let mifflinGenderCoefficient: Double = (gender == .male) ? 5 : -161
        let bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageYears)) + mifflinGenderCoefficient

        let activityMultiplier = calculateActivityMultiplier(
            dailyActivity: user?.submittedDailyActivityLevel ?? .moderate,
            exerciseFrequency: user?.submittedExerciseFrequency ?? .threeToFour
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
        dailyActivity: ActivityLevel,
        exerciseFrequency: ExerciseFrequency
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

extension CoreInteractor {
    // MARK: NutritionManager

    var currentDietPlan: DietPlan? {
        nutritionManager.currentDietPlan
    }

    func computeDietPlan(user: UserModel?, delegate: DietPlanDelegate) -> DietPlan {
        nutritionManager.computeDietPlan(user: user, delegate: delegate, trainingProgram: activeTrainingProgram)
    }

    func saveDietPlan(plan: DietPlan) async throws {
        try await nutritionManager.saveDietPlan(plan: plan)
    }

    func createAndSaveDietPlan(user: UserModel?, delegate: DietPlanDelegate) async throws {
        try await nutritionManager.createAndSaveDietPlan(user: user, delegate: delegate, trainingProgram: activeTrainingProgram)
    }

    // Get daily macro target for a specific date from the current diet plan
    func getDailyTarget(for date: Date, userId: String) async throws -> DailyMacroTarget? {
        try await nutritionManager.getDailyTarget(for: date, userId: userId)
    }

    // Estimation
    func estimateTDEE(user: UserModel?) -> Double {
        nutritionManager.estimateTDEE(user: user)
    }

}
