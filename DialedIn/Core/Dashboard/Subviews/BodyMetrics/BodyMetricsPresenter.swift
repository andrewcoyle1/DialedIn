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
    
    func onScaleWeightPressed() {
        router.showScaleWeightView(delegate: ScaleWeightDelegate())
    }
    
    func onVisualBodyFatPressed() {
        router.showVisualBodyFatView(delegate: VisualBodyFatDelegate())
    }
 
    func onNeckMeasurementPressed() {
        router.showNeckMeasurementView(delegate: NeckMeasurementDelegate())
    }
    
    func onShouldersMeasurementPressed() {
        router.showShouldersMeasurementView(delegate: ShouldersMeasurementDelegate())
    }
    
    func onBustMeasurementPressed() {
        router.showBustMeasurementView(delegate: BustMeasurementDelegate())
    }
    
    func onChestMeasurementPressed() {
        router.showChestMeasurementView(delegate: ChestMeasurementDelegate())
    }
    
    func onWaistMeasurementPressed() {
        router.showWaistMeasurementView(delegate: WaistMeasurementDelegate())
    }
    
    func onHipsMeasurementPressed() {
        router.showHipsMeasurementView(delegate: HipsMeasurementDelegate())
    }
    
    func onLeftBicepMeasurementPressed() {
        router.showLeftBicepMeasurementView(delegate: LeftBicepMeasurementDelegate())
    }
    
    func onRightBicepMeasurementPressed() {
        router.showRightBicepMeasurementView(delegate: RightBicepMeasurementDelegate())
    }
    
    func onLeftForearmMeasurementPressed() {
        router.showLeftForearmMeasurementView(delegate: LeftForearmMeasurementDelegate())
    }
    
    func onRightForearmMeasurementPressed() {
        router.showRightForearmMeasurementView(delegate: RightForearmMeasurementDelegate())
    }
    
    func onLeftWristMeasurementPressed() {
        router.showLeftWristMeasurementView(delegate: LeftWristMeasurementDelegate())
    }
    
    func onRightWristMeasurementPressed() {
        router.showRightWristMeasurementView(delegate: RightWristMeasurementDelegate())
    }
    
    func onLeftThighMeasurementPressed() {
        router.showLeftThighMeasurementView(delegate: LeftThighMeasurementDelegate())
    }
    
    func onRightThighMeasurementPressed() {
        router.showRightThighMeasurementView(delegate: RightThighMeasurementDelegate())
    }
    
    func onLeftCalfMeasurementPressed() {
        router.showLeftCalfMeasurementView(delegate: LeftCalfMeasurementDelegate())
    }
    
    func onRightCalfMeasurementPressed() {
        router.showRightCalfMeasurementView(delegate: RightCalfMeasurementDelegate())
    }
    
    func onLeftAnkleMeasurementPressed() {
        router.showLeftAnkleMeasurementView(delegate: LeftAnkleMeasurementDelegate())
    }
    
    func onRightAnkleMeasurementPressed() {
        router.showRightAnkleMeasurementView(delegate: RightAnkleMeasurementDelegate())
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
    func onFirstTask() async {
        _ = try? interactor.readAllLocalWeightEntries()
    }
    
    private var scaleWeightLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.weightKg != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var scaleWeightSparklineData: [(date: Date, value: Double)] {
        scaleWeightLastEntries.compactMap { entry in
            guard let weightKg = entry.weightKg else { return nil }
            return (date: entry.date, value: weightKg)
        }
    }
    
    var scaleWeightSubtitle: String {
        scaleWeightLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var scaleWeightLatestValueText: String {
        guard let latest = scaleWeightLastEntries.last,
              let weightKg = latest.weightKg else { return "--" }
        return weightKg.formatted(.number.precision(.fractionLength(1)))
    }
    
    var scaleWeightUnitText: String {
        "kg"
    }
    
    private var bodyFatLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.bodyFatPercentage != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var bodyFatSparklineData: [(date: Date, value: Double)] {
        bodyFatLastEntries.compactMap { entry in
            guard let bodyFatPercentage = entry.bodyFatPercentage else { return nil }
            return (date: entry.date, value: bodyFatPercentage)
        }
    }
    
    var bodyFatSubtitle: String {
        bodyFatLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var bodyFatLatestValueText: String {
        guard let latest = bodyFatLastEntries.last,
              let bodyFatPercentage = latest.bodyFatPercentage else {
            return "--"
        }
        return bodyFatPercentage.formatted(.number.precision(.fractionLength(1)))
    }
    
    var bodyFatUnitText: String {
        "%"
    }
            
    private var neckLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.neckCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var neckSparklineData: [(date: Date, value: Double)] {
        neckLastEntries.compactMap { entry in
            guard let neckCircumference = entry.neckCircumference else { return nil }
            return (date: entry.date, value: neckCircumference)
        }
    }
    
    var neckCircumferenceSubtitle: String {
        neckLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var neckLatestValueText: String {
        guard let latest = neckLastEntries.last,
              let neckCircumference = latest.neckCircumference else {
            return "--"
        }
        return neckCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var neckUnitText: String {
        "in"
    }

    private var shouldersLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.shoulderCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var shouldersSparklineData: [(date: Date, value: Double)] {
        shouldersLastEntries.compactMap { entry in
            guard let shoulderCircumference = entry.shoulderCircumference else { return nil }
            return (date: entry.date, value: shoulderCircumference)
        }
    }
    
    var shoulderCircumferenceSubtitle: String {
        shouldersLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var shouldersLastEntriesLatestValueText: String {
        guard let latest = shouldersLastEntries.last,
              let shoulderCircumference = latest.shoulderCircumference else {
            return "--"
        }
        return shoulderCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var shouldersUnitText: String {
        "in"
    }

    private var bustLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.bustCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var bustSparklineData: [(date: Date, value: Double)] {
        bustLastEntries.compactMap { entry in
            guard let bustCircumference = entry.bustCircumference else { return nil }
            return (date: entry.date, value: bustCircumference)
        }
    }
    
    var bustSubtitle: String {
        bustLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var bustLatestValueText: String {
        guard let latest = bustLastEntries.last,
              let bustCircumference = latest.bustCircumference else {
            return "--"
        }
        return bustCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var bustUnitText: String {
        "in"
    }

    private var chestLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.chestCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var chestSparklineData: [(date: Date, value: Double)] {
        chestLastEntries.compactMap { entry in
            guard let chestCircumference = entry.chestCircumference else { return nil }
            return (date: entry.date, value: chestCircumference)
        }
    }
    
    var chestSubtitle: String {
        chestLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var chestLatestValueText: String {
        guard let latest = chestLastEntries.last,
              let chestCircumference = latest.chestCircumference else {
            return "--"
        }
        return chestCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var chestUnitText: String {
        "in"
    }

    private var waistLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.waistCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var waistSparklineData: [(date: Date, value: Double)] {
        waistLastEntries.compactMap { entry in
            guard let waistCircumference = entry.waistCircumference else { return nil }
            return (date: entry.date, value: waistCircumference)
        }
    }
    
    var waistSubtitle: String {
        waistLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var waistLatestValueText: String {
        guard let latest = waistLastEntries.last,
              let waistCircumference = latest.waistCircumference else {
            return "--"
        }
        return waistCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var waistUnitText: String {
        "in"
    }

    private var hipsLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.hipCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var hipsSparklineData: [(date: Date, value: Double)] {
        hipsLastEntries.compactMap { entry in
            guard let hipCircumference = entry.hipCircumference else { return nil }
            return (date: entry.date, value: hipCircumference)
        }
    }
    
    var hipsSubtitle: String {
        hipsLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var hipsLatestValueText: String {
        guard let latest = hipsLastEntries.last,
              let hipCircumference = latest.hipCircumference else {
            return "--"
        }
        return hipCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var hipsUnitText: String {
        "in"
    }

    private var leftBicepLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.leftBicepCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var leftBicepSparklineData: [(date: Date, value: Double)] {
        leftBicepLastEntries.compactMap { entry in
            guard let leftBicepCircumference = entry.leftBicepCircumference else { return nil }
            return (date: entry.date, value: leftBicepCircumference)
        }
    }
    
    var leftBicepSubtitle: String {
        leftBicepLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var leftBicepLatestValueText: String {
        guard let latest = leftBicepLastEntries.last,
              let leftBicepCircumference = latest.leftBicepCircumference else {
            return "--"
        }
        return leftBicepCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var leftBicepUnitText: String {
        "in"
    }

    private var rightBicepLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.rightBicepCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var rightBicepSparklineData: [(date: Date, value: Double)] {
        rightBicepLastEntries.compactMap { entry in
            guard let rightBicepCircumference = entry.rightBicepCircumference else { return nil }
            return (date: entry.date, value: rightBicepCircumference)
        }
    }
    
    var rightBicepSubtitle: String {
        rightBicepLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var rightBicepLatestValueText: String {
        guard let latest = rightBicepLastEntries.last,
              let rightBicepCircumference = latest.rightBicepCircumference else {
            return "--"
        }
        return rightBicepCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var rightBicepUnitText: String {
        "in"
    }

    private var leftForearmLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.leftForearmCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var leftForearmSparklineData: [(date: Date, value: Double)] {
        leftForearmLastEntries.compactMap { entry in
            guard let leftForearmCircumference = entry.leftForearmCircumference else { return nil }
            return (date: entry.date, value: leftForearmCircumference)
        }
    }
    
    var leftForearmSubtitle: String {
        leftForearmLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var leftForearmLatestValueText: String {
        guard let latest = leftForearmLastEntries.last,
              let leftForearmCircumference = latest.leftForearmCircumference else {
            return "--"
        }
        return leftForearmCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var leftForearmUnitText: String {
        "in"
    }

    private var rightForearmLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.rightForearmCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    var rightForearmSparklineData: [(date: Date, value: Double)] {
        rightForearmLastEntries.compactMap { entry in
            guard let rightForearmCircumference = entry.rightForearmCircumference else { return nil }
            return (date: entry.date, value: rightForearmCircumference)
        }
    }
    
    var rightForearmSubtitle: String {
        rightForearmLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var rightForearmLatestValueText: String {
        guard let latest = rightForearmLastEntries.last,
              let rightForearmCircumference = latest.rightForearmCircumference else {
            return "--"
        }
        return rightForearmCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var rightForearmUnitText: String {
        "in"
    }

    private var leftWristLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.leftWristCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var leftWristSparklineData: [(date: Date, value: Double)] {
        leftWristLastEntries.compactMap { entry in
            guard let leftWristCircumference = entry.leftWristCircumference else { return nil }
            return (date: entry.date, value: leftWristCircumference)
        }
    }
    
    var leftWristSubtitle: String {
        leftWristLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var leftWristLatestValueText: String {
        guard let latest = leftWristLastEntries.last,
              let leftWristCircumference = latest.leftWristCircumference else {
            return "--"
        }
        return leftWristCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var leftWristUnitText: String {
        "in"
    }

    private var rightWristLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.rightWristCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var rightWristSparklineData: [(date: Date, value: Double)] {
        rightWristLastEntries.compactMap { entry in
            guard let rightWristCircumference = entry.rightWristCircumference else { return nil }
            return (date: entry.date, value: rightWristCircumference)
        }
    }
    
    var rightWristSubtitle: String {
        rightWristLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var rightWristLatestValueText: String {
        guard let latest = rightWristLastEntries.last,
              let rightWristCircumference = latest.rightWristCircumference else {
            return "--"
        }
        return rightWristCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var rightWristUnitText: String {
        "in"
    }

    private var leftThighLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.leftThighCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var leftThighSparklineData: [(date: Date, value: Double)] {
        leftThighLastEntries.compactMap { entry in
            guard let leftThighCircumference = entry.leftThighCircumference else { return nil }
            return (date: entry.date, value: leftThighCircumference)
        }
    }
    
    var leftThighSubtitle: String {
        leftThighLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var leftThighLatestValueText: String {
        guard let latest = leftThighLastEntries.last,
              let leftThighCircumference = latest.leftThighCircumference else {
            return "--"
        }
        return leftThighCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var leftThighUnitText: String {
        "in"
    }

    private var rightThighLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.rightThighCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var rightThighSparklineData: [(date: Date, value: Double)] {
        rightThighLastEntries.compactMap { entry in
            guard let rightThighCircumference = entry.rightThighCircumference else { return nil }
            return (date: entry.date, value: rightThighCircumference)
        }
    }
    
    var rightThighSubtitle: String {
        rightThighLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var rightThighLatestValueText: String {
        guard let latest = rightThighLastEntries.last,
              let rightThighCircumference = latest.rightThighCircumference else {
            return "--"
        }
        return rightThighCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var rightThighUnitText: String {
        "in"
    }

    private var leftCalfLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.leftCalfCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var leftCalfSparklineData: [(date: Date, value: Double)] {
        leftCalfLastEntries.compactMap { entry in
            guard let leftCalfCircumference = entry.leftCalfCircumference else { return nil }
            return (date: entry.date, value: leftCalfCircumference)
        }
    }
    
    var leftCalfSubtitle: String {
        leftCalfLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var leftCalfLatestValueText: String {
        guard let latest = leftCalfLastEntries.last,
              let leftCalfCircumference = latest.leftCalfCircumference else {
            return "--"
        }
        return leftCalfCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var leftCalfUnitText: String {
        "in"
    }

    private var rightCalfLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.rightCalfCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var rightCalfSparklineData: [(date: Date, value: Double)] {
        rightCalfLastEntries.compactMap { entry in
            guard let rightCalfCircumference = entry.rightCalfCircumference else { return nil }
            return (date: entry.date, value: rightCalfCircumference)
        }
    }
    
    var rightCalfSubtitle: String {
        rightCalfLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var rightCalfLatestValueText: String {
        guard let latest = rightCalfLastEntries.last,
              let rightCalfCircumference = latest.rightCalfCircumference else {
            return "--"
        }
        return rightCalfCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var rightCalfUnitText: String {
        "in"
    }

    private var leftAnkleLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.leftAnkleCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var leftAnkleSparklineData: [(date: Date, value: Double)] {
        leftAnkleLastEntries.compactMap { entry in
            guard let leftAnkleCircumference = entry.leftAnkleCircumference else { return nil }
            return (date: entry.date, value: leftAnkleCircumference)
        }
    }
    
    var leftAnkleSubtitle: String {
        leftAnkleLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var leftAnkleLatestValueText: String {
        guard let latest = leftAnkleLastEntries.last,
              let leftAnkleCircumference = latest.leftAnkleCircumference else {
            return "--"
        }
        return leftAnkleCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var leftAnkleUnitText: String {
        "in"
    }

    private var rightAnkleLastEntries: [BodyMeasurementEntry] {
        let filtered = measurementHistory.filter {
            $0.deletedAt == nil && $0.rightAnkleCircumference != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
    
    var rightAnkleSparklineData: [(date: Date, value: Double)] {
        rightAnkleLastEntries.compactMap { entry in
            guard let rightAnkleCircumference = entry.rightAnkleCircumference else { return nil }
            return (date: entry.date, value: rightAnkleCircumference)
        }
    }
    
    var rightAnkleSubtitle: String {
        rightAnkleLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }
    
    var rightAnkleLatestValueText: String {
        guard let latest = rightAnkleLastEntries.last,
              let rightAnkleCircumference = latest.rightAnkleCircumference else {
            return "--"
        }
        return rightAnkleCircumference.formatted(.number.precision(.fractionLength(1)))
    }
    
    var rightAnkleUnitText: String {
        "in"
    }

}
