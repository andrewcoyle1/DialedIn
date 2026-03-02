import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showProfileView()
    func showNotificationsView()
    func showDevSettingsView()
}

extension CoreRouter: DashboardRouter { }
