//
//  OnboardingExpenditureViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingExpenditureInteractor: Sendable {
    func saveCompleteAccountSetupProfile(userBuilder: UserModelBuilder, onboardingStep: OnboardingStep) async throws -> UserModel
    func estimateTDEE(user: UserModel?) -> Double
    func handleAuthError(_ error: Error, operation: String) -> AuthErrorInfo
    func updateOnboardingStep(step: OnboardingStep) async throws
    func canRequestNotificationAuthorisation() async -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingExpenditureInteractor { }

@Observable
@MainActor
class OnboardingExpenditureViewModel {
    private let interactor: OnboardingExpenditureInteractor
    
    private var canRequestNotifications: Bool?
    private var canRequestHealthData: Bool?

    // Computed from collected data
    var totalExpenditureKcal: Int = 0
    struct ExpenditureContext {
        let weight: Double
        let height: Double
        let dateOfBirth: Date
        let gender: Gender
        let activityLevel: ActivityLevel
        let exerciseFrequency: ExerciseFrequency
    }

    func breakdownItems(context: ExpenditureContext) -> [Breakdown] {
        // Breakdown aligned with the actual formula used for TDEE
        // TDEE = BMR * (baseActivityMultiplier + exerciseAdjustment)
        let bmrCals = bmrInt(
            weight: context.weight,
            height: context.height,
            dateOfBirth: context.dateOfBirth,
            gender: context.gender
        )
        let baseBmr = bmr(
            weight: context.weight,
            height: context.height,
            dateOfBirth: context.dateOfBirth,
            gender: context.gender
        )
        let activityCals = max(Int((baseBmr * max(baseActivityMultiplier(activityLevel: context.activityLevel) - 1.0, 0)).rounded()), 0)
        let exerciseCals = max(Int((baseBmr * max(exerciseAdjustment(exerciseFrequency: context.exerciseFrequency), 0)).rounded()), 0)
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
    
    private func ageYears(dateOfBirth: Date) -> Int {
        let years = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 30
        return max(14, years)
    }
    
    private func weightKg(weight: Double) -> Double { max(weight, 30) }
    private func heightCm(height: Double) -> Double { max(height, 120) }
    private func mifflinGenderCoefficient(gender: Gender) -> Double { (gender == .male) ? 5 : -161 }
    private func bmr(weight: Double, height: Double, dateOfBirth: Date, gender: Gender) -> Double { (10 * weightKg(weight: weight)) + (6.25 * heightCm(height: height)) - (5 * Double(ageYears(dateOfBirth: dateOfBirth))) + mifflinGenderCoefficient(gender: gender) }
    func bmrInt(
        weight: Double,
        height: Double,
        dateOfBirth: Date,
        gender: Gender
    ) -> Int {
        Int(
            bmr(
                weight: weight,
                height: height,
                dateOfBirth: dateOfBirth,
                gender: gender
            ).rounded()
        )
    }

    func baseActivityMultiplier(activityLevel: ActivityLevel) -> Double {
        switch mapDailyActivityLevel(activityLevel) {
        case .sedentary: return 1.2
        case .light: return 1.35
        case .moderate: return 1.5
        case .active: return 1.7
        case .veryActive: return 1.9
        }
    }
    func activityDescription(activityLevel: ActivityLevel) -> String {
        switch activityLevel {
        case .sedentary: return "Mostly sitting; little movement"
        case .light: return "Light movement most of the day"
        case .moderate: return "On feet or moving regularly"
        case .active: return "Physically active work or lifestyle"
        case .veryActive: return "Highly active throughout the day"
        }
    }
    
    func exerciseAdjustment(exerciseFrequency: ExerciseFrequency) -> Double {
        switch exerciseFrequency {
        case .never: return 0.0
        case .oneToTwo: return 0.05
        case .threeToFour: return 0.10
        case .fiveToSix: return 0.15
        case .daily: return 0.20
        }
    }
    
    func exerciseDescription(exerciseFrequency: ExerciseFrequency) -> String {
        switch exerciseFrequency {
        case .never: return "No structured exercise"
        case .oneToTwo: return "1–2 sessions per week"
        case .threeToFour: return "3–4 sessions per week"
        case .fiveToSix: return "5–6 sessions per week"
        case .daily: return "Exercise most days"
        }
    }
    
    private func tdeeFromContext(_ context: ExpenditureContext) -> Double {
        max(
            1000,
            bmr(
                weight: context.weight,
                height: context.height,
                dateOfBirth: context.dateOfBirth,
                gender: context.gender
            ) * (
                baseActivityMultiplier(activityLevel: context.activityLevel) + exerciseAdjustment(exerciseFrequency: context.exerciseFrequency)
            )
        )
    }
    
    func tdeeInt(context: ExpenditureContext) -> Int {
        Int(
            tdeeFromContext(context).rounded()
        )
    }

    init(interactor: OnboardingExpenditureInteractor) {
        self.interactor = interactor
    }
    
    struct Breakdown: Identifiable {
        let id = UUID()
        let name: String
        let calories: Int
        let color: Color
    }

    func checkCanRequestPermissions() async {
        self.canRequestHealthData = interactor.canRequestHealthDataAuthorisation()
        self.canRequestNotifications = await interactor.canRequestNotificationAuthorisation()
    }

    private func navigateForward(path: Binding<[OnboardingPathOption]>) async {
        if let canRequestNotifs = self.canRequestNotifications, canRequestNotifs {
            interactor.trackEvent(event: Event.navigate(destination: .notifications))
            path.wrappedValue.append(.notifications)
        } else if let canRequestHealth = canRequestHealthData, canRequestHealth {
            interactor.trackEvent(event: Event.navigate(destination: .healthData))
            path.wrappedValue.append(.healthData)
        } else {
            do {
                try await interactor.updateOnboardingStep(step: .healthDisclaimer)
                interactor.trackEvent(event: Event.navigate(destination: .healthDisclaimer))
                path.wrappedValue.append(.healthDisclaimer)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func progress(for item: Breakdown) -> Double {
        guard totalExpenditureKcal > 0 else { return 0 }
        return Double(item.calories) / Double(totalExpenditureKcal)
    }
    
    func estimateExpenditure(userModelBuilder: UserModelBuilder) {
        // Local-only estimation. No network calls, no alerts.
        guard let weight = userModelBuilder.weight,
              let height = userModelBuilder.height,
              let dateOfBirth = userModelBuilder.dateOfBirth,
              let activityLevel = userModelBuilder.activityLevel,
              let exerciseFrequency = userModelBuilder.exerciseFrequency else {
            isLoading = false
            return
        }

        let context = ExpenditureContext(
            weight: weight,
            height: height,
            dateOfBirth: dateOfBirth,
            gender: userModelBuilder.gender,
            activityLevel: activityLevel,
            exerciseFrequency: exerciseFrequency
        )
        totalExpenditureKcal = tdeeInt(context: context)
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
        isLoading = false
    }

    func saveAndNavigate(path: Binding<[OnboardingPathOption]>, userModelBuilder: UserModelBuilder) {
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
                guard userModelBuilder.dateOfBirth != nil,
                      userModelBuilder.height != nil,
                      userModelBuilder.weight != nil,
                      userModelBuilder.exerciseFrequency != nil,
                      userModelBuilder.activityLevel != nil,
                      userModelBuilder.cardioFitness != nil,
                      userModelBuilder.lengthUnitPreference != nil,
                      userModelBuilder.weightUnitPreferene != nil else {
                    handleMissingUserDraft(path: path, userModelBuilder: userModelBuilder)
                    return
                }

                let canNotifs = self.canRequestNotifications ?? false
                let canHealth = self.canRequestHealthData ?? false
                let targetStep: OnboardingStep = canNotifs ? .notifications : (canHealth ? .healthData : .healthDisclaimer)

                let updated = try await performOperationWithTimeout {
                    try await self.interactor.saveCompleteAccountSetupProfile(userBuilder: userModelBuilder, onboardingStep: targetStep)
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
                await navigateForward(path: path)
            } catch {
                interactor.trackEvent(event: Event.profileSaveFail(error: error))
                handleSaveError(error, path: path, userModelBuilder: userModelBuilder)
            }
        }
    }
    
    // MARK: - Error Handling Helpers
    
    private func handleSaveError(_ error: Error, path: Binding<[OnboardingPathOption]>, userModelBuilder: UserModelBuilder) {

        let errorInfo = interactor.handleAuthError(error, operation: "save profile")
        
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message,
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        if errorInfo.isRetryable {
                            Button("Try Again") { self.saveAndNavigate(path: path, userModelBuilder: userModelBuilder) }
                        }
                    }
                )
            }
        )
    }

    private func handleMissingUserDraft(path: Binding<[OnboardingPathOption]>, userModelBuilder: UserModelBuilder) {
        isSaving = false
        isLoading = false
        showAlert = AnyAppAlert(
            title: "Unable to Load Profile",
            subtitle: "We couldn’t load your saved details. Please try again.",
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        Button("Try Again") { self.saveAndNavigate(path: path, userModelBuilder: userModelBuilder) }
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
        case navigate(destination: OnboardingPathOption)
        
        var eventName: String {
            switch self {
            case .profileSaveStart: return "OnboardingExpenditure_SaveProfile_Start"
            case .profileSaveSuccess: return "OnboardingExpenditure_SaveProfile_Success"
            case .profileSaveFail: return "OnboardingExpenditureo_SaveProfile_Fail"
            case .navigate: return "OnboardingExpenditure_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .profileSaveFail(error: let error):
                return error.eventParameters
            case .navigate(destination: let destination):
                return destination.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .profileSaveFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
            }
        }
    }
}
