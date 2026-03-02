import SwiftUI

@MainActor
protocol BodyMetricsRouter: GlobalRouter {
    func showScaleWeightView(delegate: ScaleWeightDelegate, themeColor: Color?)
    func showVisualBodyFatView(delegate: VisualBodyFatDelegate, themeColor: Color?)
    func showNeckMeasurementView(delegate: NeckMeasurementDelegate, themeColor: Color?)
    func showShouldersMeasurementView(delegate: ShouldersMeasurementDelegate, themeColor: Color?)
    func showBustMeasurementView(delegate: BustMeasurementDelegate, themeColor: Color?)
    func showChestMeasurementView(delegate: ChestMeasurementDelegate, themeColor: Color?)
    func showWaistMeasurementView(delegate: WaistMeasurementDelegate, themeColor: Color?)
    func showHipsMeasurementView(delegate: HipsMeasurementDelegate, themeColor: Color?)
    func showLeftBicepMeasurementView(delegate: LeftBicepMeasurementDelegate, themeColor: Color?)
    func showRightBicepMeasurementView(delegate: RightBicepMeasurementDelegate, themeColor: Color?)
    func showLeftForearmMeasurementView(delegate: LeftForearmMeasurementDelegate, themeColor: Color?)
    func showRightForearmMeasurementView(delegate: RightForearmMeasurementDelegate, themeColor: Color?)
    func showLeftWristMeasurementView(delegate: LeftWristMeasurementDelegate, themeColor: Color?)
    func showRightWristMeasurementView(delegate: RightWristMeasurementDelegate, themeColor: Color?)
    func showLeftThighMeasurementView(delegate: LeftThighMeasurementDelegate, themeColor: Color?)
    func showRightThighMeasurementView(delegate: RightThighMeasurementDelegate, themeColor: Color?)
    func showLeftCalfMeasurementView(delegate: LeftCalfMeasurementDelegate, themeColor: Color?)
    func showRightCalfMeasurementView(delegate: RightCalfMeasurementDelegate, themeColor: Color?)
    func showLeftAnkleMeasurementView(delegate: LeftAnkleMeasurementDelegate, themeColor: Color?)
    func showRightAnkleMeasurementView(delegate: RightAnkleMeasurementDelegate, themeColor: Color?)
    
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
