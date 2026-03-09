import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showProfileView()
    func showNotificationsView()
    func showNutritionView()
    func showAddMealView(delegate: AddMealDelegate)
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: DashboardRouter { }
