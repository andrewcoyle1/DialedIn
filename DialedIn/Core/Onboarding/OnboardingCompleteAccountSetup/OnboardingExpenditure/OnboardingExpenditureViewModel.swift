//
//  OnboardingExpenditureViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingExpenditureInteractor: Sendable {
    var userDraft: UserModel? { get }
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
    
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    var gender: Gender = .male
    var height: Double = 175
    var weight: Double = 70
    var exerciseFrequency: ExerciseFrequency = .threeToFour
    var activityLevel: ActivityLevel = .moderate
    var lengthUnitPreference: LengthUnitPreference = .centimeters
    var weightUnitPreference: WeightUnitPreference = .kilograms
    var selectedCardioFitness: CardioFitnessLevel = .intermediate
        
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
        switch mapDailyActivityLevel(activityLevel) {
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
    
    init(interactor: OnboardingExpenditureInteractor) {
        self.interactor = interactor
        if !hydrateFromDraft() {
            isLoading = false
        }
    }
    
    struct Breakdown: Identifiable {
        let id = UUID()
        let name: String
        let calories: Int
        let color: Color
    }

    func navigateToHealthDisclaimer(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.healthDisclaimer)
    }
    
    func progress(for item: Breakdown) -> Double {
        guard totalExpenditureKcal > 0 else { return 0 }
        return Double(item.calories) / Double(totalExpenditureKcal)
    }
    
    func calculateExpenditure() {
        // Cancel any existing save to prevent race conditions
        currentSaveTask?.cancel()

        guard hydrateFromDraft() else {
            return
        }

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

    private func handleMissingUserDraft() {
        isSaving = false
        isLoading = false
        showAlert = AnyAppAlert(
            title: "Unable to Load Profile",
            subtitle: "We couldn’t load your saved details. Please try again.",
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        Button("Try Again") { self.calculateExpenditure() }
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
    
    // MARK: - Draft Hydration
    @discardableResult
    private func hydrateFromDraft() -> Bool {
        guard let draft = interactor.userDraft else {
            handleMissingUserDraft()
            return false
        }
        
        dateOfBirth = draft.dateOfBirth ?? defaultDateOfBirth()
        gender = draft.gender ?? .male
        height = max(draft.heightCentimeters ?? 175, 120)
        weight = max(draft.weightKilograms ?? 70, 30)
        exerciseFrequency = mapExerciseFrequency(from: draft.exerciseFrequency)
        activityLevel = mapDailyActivityLevel(from: draft.dailyActivityLevel)
        lengthUnitPreference = draft.lengthUnitPreference ?? .centimeters
        weightUnitPreference = draft.weightUnitPreference ?? .kilograms
        selectedCardioFitness = mapCardioFitnessLevel(from: draft.cardioFitnessLevel)
        return true
    }
    
    private func defaultDateOfBirth() -> Date {
        Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    }
    
    private func mapExerciseFrequency(from value: ProfileExerciseFrequency?) -> ExerciseFrequency {
        switch value {
        case .some(.never): return .never
        case .some(.oneToTwo): return .oneToTwo
        case .some(.threeToFour): return .threeToFour
        case .some(.fiveToSix): return .fiveToSix
        case .some(.daily): return .daily
        case .none: return .threeToFour
        }
    }
    
    private func mapDailyActivityLevel(from value: ProfileDailyActivityLevel?) -> ActivityLevel {
        switch value {
        case .some(.sedentary): return .sedentary
        case .some(.light): return .light
        case .some(.moderate): return .moderate
        case .some(.active): return .active
        case .some(.veryActive): return .veryActive
        case .none: return .moderate
        }
    }
    
    private func mapCardioFitnessLevel(from value: ProfileCardioFitnessLevel?) -> CardioFitnessLevel {
        switch value {
        case .some(.beginner): return .beginner
        case .some(.novice): return .novice
        case .some(.intermediate): return .intermediate
        case .some(.advanced): return .advanced
        case .some(.elite): return .elite
        case .none: return .intermediate
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
