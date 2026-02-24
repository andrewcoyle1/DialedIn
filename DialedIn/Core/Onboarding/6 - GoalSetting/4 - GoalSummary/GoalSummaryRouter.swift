//
//  GoalSummaryRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol GoalSummaryRouter: GlobalRouter {
    func showDevSettingsView()
    
    func showCompleteAccountSetupView()
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
    func showGoalSettingView()
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate)
    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate)
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()

}

extension CoreRouter: GoalSummaryRouter { }
