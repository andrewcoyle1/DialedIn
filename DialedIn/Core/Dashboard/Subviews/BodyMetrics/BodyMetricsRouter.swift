import SwiftUI

@MainActor
protocol BodyMetricsRouter: GlobalRouter {
    func showScaleWeightView(delegate: ScaleWeightDelegate)
    func showVisualBodyFatView(delegate: VisualBodyFatDelegate)
}

extension CoreRouter: BodyMetricsRouter { }
