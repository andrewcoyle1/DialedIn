//
//  ProfilePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter

    private(set) var activeGoal: WeightGoal?

    var currentUser: UserModel? {
        interactor.currentUser
    }

    var fullName: String {
        guard let user = currentUser else { return "" }
        let first = user.firstName ?? ""
        let last = user.lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }

    var currentGoal: WeightGoal? {
        interactor.currentGoal
    }
    
    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }
    
    init(
        interactor: ProfileInteractor,
        router: ProfileRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onGymProfilesPressed() {
        router.showGymProfilesView()
    }

    func getActiveGoal() async {
        if let userId = self.currentUser?.userId {
            activeGoal = try? await interactor.getActiveGoal(userId: userId)
        }
    }

    func onProfileEditPressed() {
        router.showAccountView(delegate: AccountDelegate())
//        router.showProfileEditView()
    }

    func onNotificationsPressed() {
        router.showNotificationsView()
    }

    func onExerciseLibraryPressed() {
        router.showExercisesView()
    }

    func navToExerciseTemplateList() {
        guard let templateIds = currentUser?.createdExerciseTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showExerciseTemplateListView(delegate: ExerciseTemplateListDelegate(templateIds: templateIds))
    }

    func navToWorkoutTemplateList() {
        interactor.trackEvent(event: Event.navigate)
        router.showWorkoutTemplateListView()
    }

    func navToIngredientTemplateList() {
        guard let templateIds = currentUser?.createdIngredientTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showIngredientTemplateListView(delegate: IngredientTemplateListDelegate(templateIds: templateIds))
    }

    func navToRecipeTemplateList() {
        guard let templateIds = currentUser?.createdRecipeTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showRecipeTemplateListView(delegate: RecipeTemplateListDelegate(templateIds: templateIds))
    }

    func formatUnitPreferences(length: LengthUnitPreference?, weight: WeightUnitPreference?) -> String {
        let lengthStr = length == .centimeters ? "Metric" : "Imperial"
        let weightStr = weight == .kilograms ? "Metric" : "Imperial"

        if lengthStr == weightStr {
            return lengthStr
        } else {
            return "Mixed"
        }
    }

    func navToSettingsView() {
        interactor.trackEvent(event: Event.navigate)
        router.showSettingsView()
    }

    func navToNutritionDetail() {
        interactor.trackEvent(event: Event.navigate)
        router.showProfileNutritionDetailView()
    }

    func onLegalPressed() {

    }

    func onAppIconPressed() {

    }

    func onTutorialPressed() {

    }

    func onAboutPressed() {
        
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func updateAppState(showTabBarView: Bool) {
        interactor.updateAppState(showTabBarView: showTabBarView)
    }

    func formatHeight(_ heightCm: Double, unit: LengthUnitPreference) -> String {
        switch unit {
        case .centimeters:
            return String(format: "%.0f cm", heightCm)
        case .inches:
            let totalInches = heightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
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

    func calculateBMI(heightCm: Double, weightKg: Double) -> Double {
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }

    func formatExerciseFrequency(_ frequency: ProfileExerciseFrequency) -> String {
        switch frequency {
        case .never: return "Never"
        case .oneToTwo: return "1-2 times/week"
        case .threeToFour: return "3-4 times/week"
        case .fiveToSix: return "5-6 times/week"
        case .daily: return "Daily"
        }
    }

    func formatActivityLevel(_ level: ProfileDailyActivityLevel) -> String {
        switch level {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        }
    }

    func formatCardioFitness(_ level: ProfileCardioFitnessLevel) -> String {
        switch level {
        case .beginner: return "Beginner"
        case .novice: return "Novice"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .elite: return "Elite"
        }
    }

    func navToPhysicalStats() {
        interactor.trackEvent(event: Event.navigate)
        router.showPhysicalStatsView()
    }

    func navToProfileGoals() {
        interactor.trackEvent(event: Event.navigate)
        router.showProfileGoalsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate:     return "Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
