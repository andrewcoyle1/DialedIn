import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showProfileView()
    func showNotificationsView()
    func showWorkoutTemplateDetailView(delegate: WorkoutTemplateDetailDelegate)
    func showWorkoutTrackerView()
#if DEV || MOCK
func showDevSettingsView()
#endif
}

extension CoreRouter: DashboardRouter { }
