//
//  OnboardingExpenditurePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingExpenditurePresenter {
    private let interactor: OnboardingExpenditureInteractor
    private let router: OnboardingExpenditureRouter

    private var canRequestNotifications: Bool?
    private var canRequestHealthData: Bool?

    private(set) var canContinue: Bool = false
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
    var isSaving: Bool = false
    var currentSaveTask: Task<Void, Never>?
        
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

    init(
        interactor: OnboardingExpenditureInteractor,
        router: OnboardingExpenditureRouter
    ) {
        self.interactor = interactor
        self.router = router
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

    private func navigateForward(targetStep: OnboardingStep) async {
        interactor.trackEvent(event: Event.navigate)
        switch targetStep {

        case .auth:
            router.showOnboardingNotificationsView()
        case .subscription:
            router.showOnboardingNotificationsView()
        case .completeAccountSetup:
            router.showOnboardingNotificationsView()
        case .notifications:
            router.showOnboardingNotificationsView()
        case .healthData:
            router.showOnboardingHealthDataView()
        case .healthDisclaimer:
            router.showOnboardingHealthDisclaimerView()
        case .goalSetting:
            router.showOnboardingNotificationsView()
        case .customiseProgram:
            router.showOnboardingNotificationsView()
        case .complete:
            router.showOnboardingNotificationsView()
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
            router.dismissModal()
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

        router.dismissModal()
        canContinue = true
    }

    func saveAndNavigate(userModelBuilder: UserModelBuilder) {
        // Cancel any existing save to prevent race conditions
        currentSaveTask?.cancel()

        guard canContinue == true else { return }
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
                    handleMissingUserDraft(userModelBuilder: userModelBuilder)
                    return
                }

                let canNotifs = self.canRequestNotifications ?? false
                let canHealth = self.canRequestHealthData ?? false
                let targetStep: OnboardingStep = canNotifs ? .notifications : (canHealth ? .healthData : .healthDisclaimer)

                _ = try await interactor.saveCompleteAccountSetupProfile(userBuilder: userModelBuilder, onboardingStep: targetStep)
                interactor.trackEvent(event: Event.profileSaveSuccess)
                
                router.dismissModal()

                await navigateForward(targetStep: targetStep)
            } catch {
                interactor.trackEvent(event: Event.profileSaveFail(error: error))
                router.showAlert(
                    title: "Unable to Save Profile",
                    subtitle: "Please check your internet connection and try again.",
                    buttons: {
                        AnyView(
                            HStack {
                                Button("Cancel") { }
                                Button("Try Again") {
                                    self.saveAndNavigate(userModelBuilder: userModelBuilder)
                                }
                            }
                        )
                    }
                )            }
        }
    }
    
    private func handleMissingUserDraft(userModelBuilder: UserModelBuilder) {
        isSaving = false
        router.dismissModal()
        router.showAlert(
            title: "Unable to Load Profile",
            subtitle: "We couldn’t load your saved details. Please try again.",
            buttons: {
                AnyView(
                    HStack {
                        Button("Cancel") { }
                        Button("Try Again") { self.saveAndNavigate(userModelBuilder: userModelBuilder) }
                    }
                )
            }
        )
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

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case profileSaveStart
        case profileSaveSuccess
        case profileSaveFail(error: Error)
        case navigate
        
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
