//
//  ProfilePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import SwiftfulUtilities

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

    func onWorkoutSettingsPressed() {
        router.showWorkoutSettingsView(delegate: WorkoutSettingsDelegate())
    }

    func getActiveGoal() async {
        if let userId = self.currentUser?.userId {
            activeGoal = try? await interactor.getActiveGoal(userId: userId)
        }
    }
    
    func onUnitsPressed() {
        router.showUnitsView(delegate: UnitsDelegate())
    }

    func onIntegrationsPressed() {
        router.showIntegrationsView(delegate: IntegrationsDelegate())
    }
    
    func onSiriPressed() {
        router.showSiriView(delegate: SiriDelegate())
    }
    
    func onProfileEditPressed() {
        router.showAccountView(delegate: AccountDelegate())
    }

    func onNotificationsPressed() {
        router.showNotificationsView()
    }
    
    func onSubscriptionPressed() {
        router.showCorePaywall()
    }

    func onExerciseLibraryPressed() {
        router.showExercisesView()
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
    
    func onShortcutsPressed() {
        router.showShortcutsView(delegate: ShortcutsDelegate())
    }
    
    func onCustomiseDashboardPressed() {
        router.showCustomiseDashboardView(delegate: CustomiseDashboardDelegate())
    }

    func onLegalPressed() {
        router.showLegalView(delegate: LegalDelegate())
    }
    
    func onRatingsButtonPressed() {
        interactor.trackEvent(event: Event.ratingsPressed)
        
        func onEnjoyingAppYesPressed() {
            interactor.trackEvent(event: Event.ratingsYesPressed)
            router.dismissModal()
            AppStoreRatingsHelper.requestRatingsReview()
        }
        
        func onEnjoyingAppNoPressed() {
            interactor.trackEvent(event: Event.ratingsNoPressed)
            router.dismissModal()
        }
        
        router.showRatingsModal(
            onYesPressed: onEnjoyingAppYesPressed,
            onNoPressed: onEnjoyingAppNoPressed
        )
    }
    
    func onFoodLogSettingsPressed() {
        router.showFoodLogSettingsView(delegate: FoodLogSettingsDelegate())
    }

    func onExpenditureSettingsPressed() {
        router.showExpenditureSettingsView(delegate: ExpenditureSettingsDelegate())
    }
    
    func onStrategySettingsPressed() {
        router.showStrategySettingsView(delegate: StrategySettingsDelegate())
    }
    func onAppIconPressed() {
        router.showAppIconView(delegate: AppIconDelegate())
    }

    func onTutorialPressed() {
        router.showTutorialsView(delegate: TutorialsDelegate())
    }

    func onAboutPressed() {
        router.showAboutView(delegate: AboutDelegate())
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

    enum Event: LoggableEvent {
        case navigate
        case ratingsPressed
        case ratingsYesPressed
        case ratingsNoPressed

        var eventName: String {
            switch self {
            case .navigate:     return "Fail"
            case .ratingsPressed:               return "SettingsView_Ratings_Pressed"
            case .ratingsYesPressed:            return "SettingsView_RatingsYes_Pressed"
            case .ratingsNoPressed:             return "SettingsView_RatingsNo_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .ratingsPressed, .ratingsYesPressed, .ratingsNoPressed:
                return .analytic
            case .navigate:
                return .info
            }
        }
    }
}
