import SwiftUI

@MainActor
protocol NutritionAnalyticsRouter: GlobalRouter {
    func showNutritionMetricDetailView(metric: NutritionMetric, delegate: NutritionMetricDetailDelegate)
}

extension CoreRouter: NutritionAnalyticsRouter { }
