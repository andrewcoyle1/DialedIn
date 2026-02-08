import SwiftUI

@MainActor
protocol HabitsRouter: GlobalRouter {
    func showScaleWeightView(delegate: ScaleWeightDelegate)
    func showWorkoutView(delegate: WorkoutDelegate)
    func showNutritionMetricDetailView(metric: NutritionMetric, delegate: NutritionMetricDetailDelegate)
}

extension CoreRouter: HabitsRouter { }
