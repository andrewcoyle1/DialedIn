import SwiftUI

@MainActor
protocol BodyMetricsRouter: GlobalRouter {
    func showScaleWeightView(delegate: ScaleWeightDelegate)
    func showVisualBodyFatView(delegate: VisualBodyFatDelegate)
    func showNeckMeasurementView(delegate: NeckMeasurementDelegate)
    func showShouldersMeasurementView(delegate: ShouldersMeasurementDelegate)
    func showBustMeasurementView(delegate: BustMeasurementDelegate)
    func showChestMeasurementView(delegate: ChestMeasurementDelegate)
    func showWaistMeasurementView(delegate: WaistMeasurementDelegate)
    func showHipsMeasurementView(delegate: HipsMeasurementDelegate)
    func showLeftBicepMeasurementView(delegate: LeftBicepMeasurementDelegate)
    func showRightBicepMeasurementView(delegate: RightBicepMeasurementDelegate)
    func showLeftForearmMeasurementView(delegate: LeftForearmMeasurementDelegate)
    func showRightForearmMeasurementView(delegate: RightForearmMeasurementDelegate)
    func showLeftWristMeasurementView(delegate: LeftWristMeasurementDelegate)
    func showRightWristMeasurementView(delegate: RightWristMeasurementDelegate)
    func showLeftThighMeasurementView(delegate: LeftThighMeasurementDelegate)
    func showRightThighMeasurementView(delegate: RightThighMeasurementDelegate)
    func showLeftCalfMeasurementView(delegate: LeftCalfMeasurementDelegate)
    func showRightCalfMeasurementView(delegate: RightCalfMeasurementDelegate)
    func showLeftAnkleMeasurementView(delegate: LeftAnkleMeasurementDelegate)
    func showRightAnkleMeasurementView(delegate: RightAnkleMeasurementDelegate)
    
    // Logging view methods
    func showLogNeckMeasurementView()
    func showLogShouldersMeasurementView()
    func showLogBustMeasurementView()
    func showLogChestMeasurementView()
    func showLogWaistMeasurementView()
    func showLogHipsMeasurementView()
    func showLogLeftBicepMeasurementView()
    func showLogRightBicepMeasurementView()
    func showLogLeftForearmMeasurementView()
    func showLogRightForearmMeasurementView()
    func showLogLeftWristMeasurementView()
    func showLogRightWristMeasurementView()
    func showLogLeftThighMeasurementView()
    func showLogRightThighMeasurementView()
    func showLogLeftCalfMeasurementView()
    func showLogRightCalfMeasurementView()
    func showLogLeftAnkleMeasurementView()
    func showLogRightAnkleMeasurementView()
}

extension CoreRouter: BodyMetricsRouter { }
