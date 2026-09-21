import SwiftUI

@MainActor
protocol BodyMetricsRouter: GlobalRouter {
    func showScaleWeightView(delegate: ScaleWeightDelegate, themeColor: Color?)
    func showVisualBodyFatView(delegate: VisualBodyFatDelegate, themeColor: Color?)
    func showBodyRatioView(delegate: BodyRatioDelegate, themeColor: Color?)
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
    
    func showLogMeasurementView(kind: BodyMeasurementKind)
}

extension CoreRouter: BodyMetricsRouter { }
