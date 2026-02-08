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
    func showWeightTrendView(delegate: WeightTrendDelegate)
    func showGoalProgressView(delegate: GoalProgressDelegate)
    func showEnergyBalanceView(delegate: EnergyBalanceDelegate)
    func showWorkoutView(delegate: WorkoutDelegate)
    func showExpenditureView(delegate: ExpenditureDelegate)
    func showStepsView(delegate: StepsDelegate)
    func showVisualBodyFatView(delegate: VisualBodyFatDelegate)
    func showInsightsAndAnalyticsView(delegate: InsightsAndAnalyticsDelegate)
    func showNutritionAnalyticsView(delegate: NutritionAnalyticsDelegate)
    func showNutritionMetricDetailView(metric: NutritionMetric, delegate: NutritionMetricDetailDelegate)
    func showHabitsView(delegate: HabitsDelegate)
    func showBodyMetricsView(delegate: BodyMetricsDelegate)
    func showMuscleGroupsView(delegate: MuscleGroupsDelegate)
    func showMuscleGroupDetailView(muscle: Muscles, delegate: MuscleGroupDetailDelegate)
    func showExerciseAnalyticsView(delegate: ExerciseAnalyticsDelegate)
    func showExerciseDetailView(templateId: String, name: String, delegate: ExerciseDetailDelegate)
    func showCustomiseDashboardView(delegate: CustomiseDashboardDelegate)
}

extension CoreRouter: DashboardRouter { }
