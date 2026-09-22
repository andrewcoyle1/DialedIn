import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
//    func showProfileView()
    func showProfileViewZoom(transitionId: String?, namespace: Namespace.ID)
    func showNotificationsView()
    func showNutritionView()
    func showAddMealView(delegate: AddMealDelegate)
    #if DEV || MOCK
    func showDevSettingsView()
    #endif
}

extension CoreRouter: DashboardRouter { }
