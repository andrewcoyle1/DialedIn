import SwiftUI
import Foundation

@Observable
@MainActor
class BodyMetricsPresenter {

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    private var measurementHistory: [BodyMeasurementEntry] {
        interactor.measurementHistory
    }

    init(interactor: BodyMetricsInteractor, router: BodyMetricsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func onMeasurementPressed(_ type: BodyMetricType, themeColor: Color?) {
        routeToWeightOrUpperBody(type, themeColor: themeColor)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onFirstTask() async {
        _ = try? interactor.readAllLocalWeightEntries()
    }

    var sections: [BodyMetricsSection] {
        [
            BodyMetricsSection(
                id: "weightAndBodyFat",
                header: "Weight & Body Fat",
                cards: [displayModel(for: .scaleWeight), displayModel(for: .visualBodyFat)]
            ),
            BodyMetricsSection(
                id: "upperBody",
                header: "Upper Body",
                cards: [
                    displayModel(for: .neck),
                    displayModel(for: .shoulders),
                    displayModel(for: .bust),
                    displayModel(for: .chest),
                    displayModel(for: .waist),
                    displayModel(for: .hips)
                ]
            ),
            BodyMetricsSection(
                id: "arms",
                header: "Arms",
                cards: [
                    displayModel(for: .leftBicep),
                    displayModel(for: .rightBicep),
                    displayModel(for: .leftForearm),
                    displayModel(for: .rightForearm),
                    displayModel(for: .leftWrist),
                    displayModel(for: .rightWrist)
                ]
            ),
            BodyMetricsSection(
                id: "legs",
                header: "Legs",
                cards: [
                    displayModel(for: .leftThigh),
                    displayModel(for: .rightThigh),
                    displayModel(for: .leftCalf),
                    displayModel(for: .rightCalf),
                    displayModel(for: .leftAnkle),
                    displayModel(for: .rightAnkle)
                ]
            )
        ]
    }

    func displayModel(for type: BodyMetricType) -> BodyMetricCardModel {
        let entries = lastEntries(for: type)
        let data = entries.compactMap { entry -> (date: Date, value: Double)? in
            guard let value = type.value(from: entry) else { return nil }
            return (date: entry.date, value: value)
        }
        let subtitle = entries.isEmpty ? "No Entries" : "Last 7 Entries"
        let latestValueText: String
        if let last = entries.last, let value = type.value(from: last) {
            latestValueText = value.formatted(.number.precision(.fractionLength(1)))
        } else {
            latestValueText = "--"
        }
        return BodyMetricCardModel(
            id: type,
            title: type.displayTitle,
            subtitle: subtitle,
            latestValueText: latestValueText,
            unitText: type.unit,
            sparklineData: data
        )
    }

    private func lastEntries(for type: BodyMetricType) -> [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter { entry in
            guard entry.deletedAt == nil else { return false }
            return type.value(from: entry) != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    private func routeToWeightOrUpperBody(_ type: BodyMetricType, themeColor: Color?) {
        switch type {
        case .scaleWeight:
            router.showScaleWeightView(delegate: ScaleWeightDelegate(), themeColor: themeColor)
        case .visualBodyFat:
            router.showVisualBodyFatView(delegate: VisualBodyFatDelegate(), themeColor: themeColor)
        case .neck:
            router.showNeckMeasurementView(delegate: NeckMeasurementDelegate(), themeColor: themeColor)
        case .shoulders:
            router.showShouldersMeasurementView(delegate: ShouldersMeasurementDelegate(), themeColor: themeColor)
        case .bust:
            router.showBustMeasurementView(delegate: BustMeasurementDelegate(), themeColor: themeColor)
        case .chest:
            router.showChestMeasurementView(delegate: ChestMeasurementDelegate(), themeColor: themeColor)
        case .waist:
            router.showWaistMeasurementView(delegate: WaistMeasurementDelegate(), themeColor: themeColor)
        case .hips:
            router.showHipsMeasurementView(delegate: HipsMeasurementDelegate(), themeColor: themeColor)
        case .leftBicep, .rightBicep, .leftForearm, .rightForearm, .leftWrist, .rightWrist:
            routeToArms(type, themeColor: themeColor)
        case .leftThigh, .rightThigh, .leftCalf, .rightCalf, .leftAnkle, .rightAnkle:
            routeToLegs(type, themeColor: themeColor)
        }
    }

    private func routeToArms(_ type: BodyMetricType, themeColor: Color?) {
        switch type {
        case .leftBicep:
            router.showLeftBicepMeasurementView(delegate: LeftBicepMeasurementDelegate(), themeColor: themeColor)
        case .rightBicep:
            router.showRightBicepMeasurementView(delegate: RightBicepMeasurementDelegate(), themeColor: themeColor)
        case .leftForearm:
            router.showLeftForearmMeasurementView(delegate: LeftForearmMeasurementDelegate(), themeColor: themeColor)
        case .rightForearm:
            router.showRightForearmMeasurementView(delegate: RightForearmMeasurementDelegate(), themeColor: themeColor)
        case .leftWrist:
            router.showLeftWristMeasurementView(delegate: LeftWristMeasurementDelegate(), themeColor: themeColor)
        case .rightWrist:
            router.showRightWristMeasurementView(delegate: RightWristMeasurementDelegate(), themeColor: themeColor)
        default:
            break
        }
    }

    private func routeToLegs(_ type: BodyMetricType, themeColor: Color?) {
        switch type {
        case .leftThigh:
            router.showLeftThighMeasurementView(delegate: LeftThighMeasurementDelegate(), themeColor: themeColor)
        case .rightThigh:
            router.showRightThighMeasurementView(delegate: RightThighMeasurementDelegate(), themeColor: themeColor)
        case .leftCalf:
            router.showLeftCalfMeasurementView(delegate: LeftCalfMeasurementDelegate(), themeColor: themeColor)
        case .rightCalf:
            router.showRightCalfMeasurementView(delegate: RightCalfMeasurementDelegate(), themeColor: themeColor)
        case .leftAnkle:
            router.showLeftAnkleMeasurementView(delegate: LeftAnkleMeasurementDelegate(), themeColor: themeColor)
        case .rightAnkle:
            router.showRightAnkleMeasurementView(delegate: RightAnkleMeasurementDelegate(), themeColor: themeColor)
        default:
            break
        }
    }
}

extension BodyMetricsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear

        var eventName: String {
            switch self {
            case .onAppear:             return "BodyMetricsView_Appear"
            case .onDisappear:          return "BodyMetricsView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
