import SwiftUI

struct BustMeasurementDelegate {

}

struct BustMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let bustCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        bustCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.bustCircumference = bustCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        bustCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Bust", date: date, value: bustCircumference)]
    }
}

@Observable
@MainActor
final class BustMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = BustMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [BustMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.bustCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Bust Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Bust Circumference",
            analyticsName: "BustMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Bust Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No bust measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [BustMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.bustEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogBustMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: BustMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.bustCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.bustEntries(from: localEntries)
    }

    private static func bustEntries(from entries: [BodyMeasurementEntry]) -> [BustMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let bustCircumference = entry.bustCircumference else { return nil }
                return BustMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    bustCircumference: bustCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension BustMeasurementEntry {
    static var mocks: [BustMeasurementEntry] {
        [
            BustMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), bustCircumference: 38.6),
            BustMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), bustCircumference: 38.4),
            BustMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), bustCircumference: 38.2),
            BustMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), bustCircumference: 38.1),
            BustMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), bustCircumference: 38.0),
            BustMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), bustCircumference: 37.9),
            BustMeasurementEntry(date: Date.now, bustCircumference: 37.8)
        ]
    }
}

extension CoreRouter {
    func showBustMeasurementView(delegate: BustMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.bustMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func bustMeasurementView(router: Router, delegate: BustMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: BustMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
