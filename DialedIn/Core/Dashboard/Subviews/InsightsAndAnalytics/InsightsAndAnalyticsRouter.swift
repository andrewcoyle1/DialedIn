import SwiftUI

@MainActor
protocol InsightsAndAnalyticsRouter: GlobalRouter {
    func showWeightTrendView(delegate: WeightTrendDelegate)
    func showEnergyBalanceView(delegate: EnergyBalanceDelegate)
    func showWorkoutView(delegate: WorkoutDelegate)
    func showExpenditureView(delegate: ExpenditureDelegate)
}

extension CoreRouter: InsightsAndAnalyticsRouter { }
