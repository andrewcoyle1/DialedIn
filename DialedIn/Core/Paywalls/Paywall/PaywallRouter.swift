import SwiftUI

@MainActor
protocol PaywallRouter: GlobalRouter {
    
    func showCompleteAccountSetupView()

    func showNotificationsPermissionsView()

    func showOnboardingHealthDataView()

    func showHealthDisclaimerView()

    func showGoalSettingView()
    
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate)

    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate)

    func showCustomisingDietProgramView()

    func showOnboardingCompletedView()

}

extension CoreRouter: PaywallRouter { }
