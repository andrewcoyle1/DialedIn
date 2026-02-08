import SwiftUI

@MainActor
protocol InsightsAndAnalyticsRouter: GlobalRouter {
    func showWeightTrendView(delegate: WeightTrendDelegate)
    func showGoalProgressView(delegate: GoalProgressDelegate)
    func showEnergyBalanceView(delegate: EnergyBalanceDelegate)
    func showWorkoutView(delegate: WorkoutDelegate)
    func showExpenditureView(delegate: ExpenditureDelegate)
}

extension CoreRouter: InsightsAndAnalyticsRouter { }
