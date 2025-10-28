//
//  OnboardingExpenditureViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingExpenditureInteractor: Sendable {
    // swiftlint:disable:next function_parameter_count
    func saveCompleteAccountSetupProfile(
        dateOfBirth: Date,
        gender: Gender,
        heightCentimeters: Double,
        weightKilograms: Double,
        exerciseFrequency: ProfileExerciseFrequency,
        dailyActivityLevel: ProfileDailyActivityLevel,
        cardioFitnessLevel: ProfileCardioFitnessLevel,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference
    ) async throws -> UserModel
    func estimateTDEE(user: UserModel?) -> Double
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingExpenditureInteractor { }

@Observable
@MainActor
class OnboardingExpenditureViewModel {
    private let interactor: OnboardingExpenditureInteractor
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let exerciseFrequency: ExerciseFrequency
    let activityLevel: ActivityLevel
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    let selectedCardioFitness: CardioFitnessLevel
    
    // Computed from collected data
    var totalExpenditureKcal: Int = 0
    var breakdownItems: [Breakdown] {
        // Breakdown aligned with the actual formula used for TDEE
        // TDEE = BMR * (baseActivityMultiplier + exerciseAdjustment)
        let bmrCals = bmrInt
        let activityCals = max(Int((bmr * max(baseActivityMultiplier - 1.0, 0)).rounded()), 0)
        let exerciseCals = max(Int((bmr * max(exerciseAdjustment, 0)).rounded()), 0)
        // Use remainder as TEF to ensure components sum to displayed TDEE (accounts for rounding)
        let tefCals = max(totalExpenditureKcal - bmrCals - activityCals - exerciseCals, 0)
        return [
            Breakdown(name: "Basal Metabolic Rate", calories: bmrCals, color: .blue),
            Breakdown(name: "Daily Activity", calories: activityCals, color: .green),
            Breakdown(name: "Exercise", calories: exerciseCals, color: .orange),
            Breakdown(name: "Thermic Effect of Food", calories: tefCals, color: .pink)
        ]
    }

    var displayedKcal: Int = 0
    var animateBreakdown: Bool = false
    var hasAnimated: Bool = false
    var isLoading: Bool = true
    var showAlert: AnyAppAlert?
    var isSaving: Bool = false
    var currentSaveTask: Task<Void, Never>?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    private var ageYears: Int {
        let years = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 30
        return max(14, years)
    }
    
    private var weightKg: Double { max(weight, 30) }
    private var heightCm: Double { max(height, 120) }
    private var mifflinGenderCoefficient: Double { (gender == .male) ? 5 : -161 }
    private var bmr: Double { (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageYears)) + mifflinGenderCoefficient }
    var bmrInt: Int { Int(bmr.rounded()) }

    var baseActivityMultiplier: Double {
        switch activityLevel {
        case .sedentary: return 1.2
        case .light: return 1.35
        case .moderate: return 1.5
        case .active: return 1.7
        case .veryActive: return 1.9
        }
    }
    var activityDescription: String {
        switch activityLevel {
        case .sedentary: return "Mostly sitting; little movement"
        case .light: return "Light movement most of the day"
        case .moderate: return "On feet or moving regularly"
        case .active: return "Physically active work or lifestyle"
        case .veryActive: return "Highly active throughout the day"
        }
    }
    
    var exerciseAdjustment: Double {
        switch exerciseFrequency {
        case .never: return 0.0
        case .oneToTwo: return 0.05
        case .threeToFour: return 0.10
        case .fiveToSix: return 0.15
        case .daily: return 0.20
        }
    }
    
    var exerciseDescription: String {
        switch exerciseFrequency {
        case .never: return "No structured exercise"
        case .oneToTwo: return "1–2 sessions per week"
        case .threeToFour: return "3–4 sessions per week"
        case .fiveToSix: return "5–6 sessions per week"
        case .daily: return "Exercise most days"
        }
    }
    
    private var tdeeFromInputs: Double {
        max(
            1000,
            bmr * (
                baseActivityMultiplier + exerciseAdjustment
            )
        )
    }
    
    var tdeeInt: Int { Int(tdeeFromInputs.rounded()) }
    
    init(
        interactor: OnboardingExpenditureInteractor,
        gender: Gender,
        dateOfBirth: Date,
        height: Double,
        weight: Double,
        exerciseFrequency: ExerciseFrequency,
        activityLevel: ActivityLevel,
        lengthUnitPreference: LengthUnitPreference,
        weightUnitPreference: WeightUnitPreference,
        selectedCardioFitness: CardioFitnessLevel
    ) {
        self.interactor = interactor
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.exerciseFrequency = exerciseFrequency
        self.activityLevel = activityLevel
        self.lengthUnitPreference = lengthUnitPreference
        self.weightUnitPreference = weightUnitPreference
        self.selectedCardioFitness = selectedCardioFitness
    }
    
    struct Breakdown: Identifiable {
        let id = UUID()
        let name: String
        let calories: Int
        let color: Color
    }

    func progress(for item: Breakdown) -> Double {
        guard totalExpenditureKcal > 0 else { return 0 }
        return Double(item.calories) / Double(totalExpenditureKcal)
    }
    
    func calculateExpenditure() {
        // Cancel any existing save to prevent race conditions
        currentSaveTask?.cancel()

        currentSaveTask = Task { @MainActor in
            isSaving = true
            defer {
                isSaving = false
                currentSaveTask = nil
            }

            interactor.trackEvent(event: Event.profileSaveStart)
            do {
                let updated = try await performOperationWithTimeout {
                    try await self.interactor.saveCompleteAccountSetupProfile(
                        dateOfBirth: self.dateOfBirth,
                        gender: self.gender,
                        heightCentimeters: self.height,
                        weightKilograms: self.weight,
                        exerciseFrequency: self.mapExerciseFrequency(self.exerciseFrequency),
                        dailyActivityLevel: self.mapDailyActivityLevel(self.activityLevel),
                        cardioFitnessLevel: self.mapCardioFitnessLevel(self.selectedCardioFitness),
                        lengthUnitPreference: self.lengthUnitPreference,
                        weightUnitPreference: self.weightUnitPreference
                    )
                }

                // Compute TDEE using the updated user profile
                let tdee = interactor.estimateTDEE(user: updated)
                totalExpenditureKcal = Int(tdee.rounded())
                guard !hasAnimated else { return }
                hasAnimated = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 1.6)) {
                        self.displayedKcal = self.totalExpenditureKcal
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        self.animateBreakdown = true
                    }
                }
                interactor.trackEvent(event: Event.profileSaveSuccess)
                isLoading = false
            } catch {
                interactor.trackEvent(event: Event.profileSaveFail(error: error))
                handleSaveError(error)
            }
        }
    }
    
    // MARK: - Error Handling Helpers
    
    private func handleSaveError(_ error: Error) {
        
        let errorInfo = interactor.handleAuthError(error, operation: "save profile")
        
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message,
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        if errorInfo.isRetryable {
                            Button("Try Again") { self.calculateExpenditure() }
                        }
                    }
                )
            }
        )
    }

    // MARK: - Timeout Helper
    
    @discardableResult
    private func performOperationWithTimeout<T: Sendable>(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(for: .seconds(AuthConstants.authTimeout))
                throw AuthTimeoutError.operationTimeout
            }
            guard let result = try await group.next() else {
                throw AuthTimeoutError.operationTimeout
            }
            group.cancelAll()
            return result
        }
    }
    
    // MARK: - Mapping helpers
    private func mapExerciseFrequency(_ value: ExerciseFrequency) -> ProfileExerciseFrequency {
        switch value {
        case .never: return .never
        case .oneToTwo: return .oneToTwo
        case .threeToFour: return .threeToFour
        case .fiveToSix: return .fiveToSix
        case .daily: return .daily
        }
    }

    private func mapDailyActivityLevel(_ value: ActivityLevel) -> ProfileDailyActivityLevel {
        switch value {
        case .sedentary: return .sedentary
        case .light: return .light
        case .moderate: return .moderate
        case .active: return .active
        case .veryActive: return .veryActive
        }
    }

    private func mapCardioFitnessLevel(_ value: CardioFitnessLevel) -> ProfileCardioFitnessLevel {
        switch value {
        case .beginner: return .beginner
        case .novice: return .novice
        case .intermediate: return .intermediate
        case .advanced: return .advanced
        case .elite: return .elite
        }
    }
    
    enum Event: LoggableEvent {
        case profileSaveStart
        case profileSaveSuccess
        case profileSaveFail(error: Error)
        
        var eventName: String {
            switch self {
            case .profileSaveStart: return "OnboardingCardio_SaveProfile_Start"
            case .profileSaveSuccess: return "OnboardingCardio_SaveProfile_Success"
            case .profileSaveFail: return "OnboardingCardio_SaveProfile_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .profileSaveFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .profileSaveFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
