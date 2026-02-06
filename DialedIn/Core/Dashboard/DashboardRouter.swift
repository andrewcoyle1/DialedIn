//
//  DashboardRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol DashboardRouter: GlobalRouter {
    func showNotificationsView()
    func showDevSettingsView()
    func showCorePaywall()
    func showProfileView()
    func showScaleWeightView(delegate: ScaleWeightDelegate)
    func showVisualBodyFatView(delegate: VisualBodyFatDelegate)
    func showInsightsAndAnalyticsView(delegate: InsightsAndAnalyticsDelegate)
    func showHabitsView(delegate: HabitsDelegate)
    func showBodyMetricsView(delegate: BodyMetricsDelegate)
    func showMuscleGroupsView(delegate: MuscleGroupsDelegate)
    func showExerciseAnalyticsView(delegate: ExerciseAnalyticsDelegate)
}

extension CoreRouter: DashboardRouter { }
