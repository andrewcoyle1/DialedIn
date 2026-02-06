import SwiftUI

@Observable
@MainActor
class BodyMetricsPresenter {
    
    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter
    
    private var scaleWeightEntries: [WeightEntry] {
        interactor.weightHistory
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
    
    func onDismissPressed() {
        router.dismissScreen()
    }

    func onFirstTask() async {
        _ = try? interactor.readAllLocalWeightEntries()
    }

    var scaleWeightSparklineData: [(date: Date, value: Double)] {
        scaleWeightLastEntries.map { (date: $0.date, value: $0.weightKg) }
    }

    var scaleWeightSubtitle: String {
        scaleWeightLastEntries.isEmpty ? "No Entries" : "Last 7 Entries"
    }

    var scaleWeightLatestValueText: String {
        guard let latest = scaleWeightLastEntries.last else { return "--" }
        return latest.weightKg.formatted(.number.precision(.fractionLength(1)))
    }

    var scaleWeightUnitText: String {
        "kg"
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

    private var scaleWeightLastEntries: [WeightEntry] {
        let filtered = scaleWeightEntries.filter { $0.deletedAt == nil }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }

    private var bodyFatLastEntries: [WeightEntry] {
        let filtered = scaleWeightEntries.filter {
            $0.deletedAt == nil && $0.bodyFatPercentage != nil
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        return Array(sorted.suffix(7))
    }
}
