import SwiftUI

@MainActor
protocol InsightsAndAnalyticsRouter: GlobalRouter {
    func showWeightTrendView(delegate: WeightTrendDelegate, themeColor: Color?)
    func showGoalProgressView(delegate: GoalProgressDelegate, themeColor: Color?)
    func showEnergyBalanceView(delegate: EnergyBalanceDelegate, themeColor: Color?)
    func showWorkoutView(delegate: WorkoutDelegate, themeColor: Color?)
    func showExpenditureView(delegate: ExpenditureDelegate, themeColor: Color?)
}

extension CoreRouter: InsightsAndAnalyticsRouter { }
