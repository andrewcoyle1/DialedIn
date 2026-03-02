import SwiftUI

@MainActor
protocol NutritionAnalyticsRouter: GlobalRouter {
    func showNutritionMetricDetailView(metric: NutritionMetric, delegate: NutritionMetricDetailDelegate, themeColor: Color?)
}

extension CoreRouter: NutritionAnalyticsRouter { }
