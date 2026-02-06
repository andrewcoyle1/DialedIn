import SwiftUI

struct HipsMeasurementDelegate {

}

struct HipsMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let hipCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        hipCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.hipCircumference = hipCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        hipCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Hips", date: date, value: hipCircumference)]
    }
}

@Observable
@MainActor
final class HipsMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = HipsMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [HipsMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.hipCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Hips Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Hips Circumference",
            analyticsName: "HipsMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Hips Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No hips measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [HipsMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.hipsEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogHipsMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: HipsMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.hipCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.hipsEntries(from: localEntries)
    }

    private static func hipsEntries(from entries: [BodyMeasurementEntry]) -> [HipsMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let hipCircumference = entry.hipCircumference else { return nil }
                return HipsMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    hipCircumference: hipCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension HipsMeasurementEntry {
    static var mocks: [HipsMeasurementEntry] {
        [
            HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), hipCircumference: 38.6),
            HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), hipCircumference: 38.4),
            HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), hipCircumference: 38.2),
            HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), hipCircumference: 38.1),
            HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), hipCircumference: 38.0),
            HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), hipCircumference: 37.9),
            HipsMeasurementEntry(date: Date.now, hipCircumference: 37.8)
        ]
    }
}

extension CoreRouter {
    func showHipsMeasurementView(delegate: HipsMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.hipsMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func hipsMeasurementView(router: Router, delegate: HipsMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: HipsMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
