import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showProfileView()
    func showNotificationsView()
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: DashboardRouter { }
