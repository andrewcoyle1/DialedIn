//
//  ProfileRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileRouter: GlobalRouter {
    func showAccountView(delegate: AccountDelegate)
    func showPhysicalStatsView()
    func showProfileGoalsView()
    func showProfileNutritionDetailView()
    func showSettingsView()
    func showNotificationsView()
    func showExercisesView()
    func showWorkoutSettingsView(delegate: WorkoutSettingsDelegate)
    func showGymProfilesView()
    func showTutorialsView(delegate: TutorialsDelegate)
    func showAboutView(delegate: AboutDelegate)
    func showAppIconView(delegate: AppIconDelegate)
    func showUnitsView(delegate: UnitsDelegate)
    func showIntegrationsView(delegate: IntegrationsDelegate)
    func showSiriView(delegate: SiriDelegate)
    func showLegalView(delegate: LegalDelegate)
    func showCorePaywall()
    func showShortcutsView(delegate: ShortcutsDelegate)
    func showCustomiseDashboardView(delegate: CustomiseDashboardDelegate)
    func showFoodLogSettingsView(delegate: FoodLogSettingsDelegate)
    func showExpenditureSettingsView(delegate: ExpenditureSettingsDelegate)
    func showStrategySettingsView(delegate: StrategySettingsDelegate)
}

extension CoreRouter: ProfileRouter { }
