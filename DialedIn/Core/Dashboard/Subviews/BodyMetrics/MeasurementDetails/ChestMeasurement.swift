import SwiftUI

struct ChestMeasurementDelegate {

}

struct ChestMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let chestCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        chestCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.chestCircumference = chestCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        chestCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Chest", date: date, value: chestCircumference)]
    }
}

@Observable
@MainActor
final class ChestMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ChestMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [ChestMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.chestCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Chest Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Chest Circumference",
            analyticsName: "ChestMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Chest Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No chest measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [ChestMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.chestEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogChestMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: ChestMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.chestCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.chestEntries(from: localEntries)
    }

    private static func chestEntries(from entries: [BodyMeasurementEntry]) -> [ChestMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let chestCircumference = entry.chestCircumference else { return nil }
                return ChestMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    chestCircumference: chestCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension ChestMeasurementEntry {
    static var mocks: [ChestMeasurementEntry] {
        [
            ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), chestCircumference: 42.6),
            ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), chestCircumference: 42.4),
            ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), chestCircumference: 42.2),
            ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), chestCircumference: 42.1),
            ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), chestCircumference: 42.0),
            ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), chestCircumference: 41.9),
            ChestMeasurementEntry(date: Date.now, chestCircumference: 41.8)
        ]
    }
}

extension CoreRouter {
    func showChestMeasurementView(delegate: ChestMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.chestMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func chestMeasurementView(router: Router, delegate: ChestMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: ChestMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
