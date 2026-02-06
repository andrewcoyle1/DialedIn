import SwiftUI

struct WaistMeasurementDelegate {

}

struct WaistMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let waistCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        waistCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.waistCircumference = waistCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        waistCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Waist", date: date, value: waistCircumference)]
    }
}

@Observable
@MainActor
final class WaistMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = WaistMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [WaistMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.waistCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Waist Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Waist Circumference",
            analyticsName: "WaistMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Waist Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No waist measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [WaistMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.waistEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogWaistMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: WaistMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.waistCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.waistEntries(from: localEntries)
    }

    private static func waistEntries(from entries: [BodyMeasurementEntry]) -> [WaistMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let waistCircumference = entry.waistCircumference else { return nil }
                return WaistMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    waistCircumference: waistCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension WaistMeasurementEntry {
    static var mocks: [WaistMeasurementEntry] {
        [
            WaistMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), waistCircumference: 32.6),
            WaistMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), waistCircumference: 32.4),
            WaistMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), waistCircumference: 32.2),
            WaistMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), waistCircumference: 32.1),
            WaistMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), waistCircumference: 32.0),
            WaistMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), waistCircumference: 31.9),
            WaistMeasurementEntry(date: Date.now, waistCircumference: 31.8)
        ]
    }
}

extension CoreRouter {
    func showWaistMeasurementView(delegate: WaistMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.waistMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func waistMeasurementView(router: Router, delegate: WaistMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: WaistMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
