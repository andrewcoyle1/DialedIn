import SwiftUI

struct ShouldersMeasurementDelegate {

}

struct ShouldersMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let shoulderCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        shoulderCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.shoulderCircumference = shoulderCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        shoulderCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Shoulders", date: date, value: shoulderCircumference)]
    }
}

@Observable
@MainActor
final class ShouldersMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ShouldersMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [ShouldersMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.shoulderCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Shoulders Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Shoulders Circumference",
            analyticsName: "ShouldersMeasurementView",
            yAxisSuffix: " cm",
            seriesNames: ["Shoulders Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No shoulders measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [ShouldersMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.shouldersEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogShouldersMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: ShouldersMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.shoulderCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.shouldersEntries(from: localEntries)
    }

    private static func shouldersEntries(from entries: [BodyMeasurementEntry]) -> [ShouldersMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let shoulderCircumference = entry.shoulderCircumference else { return nil }
                return ShouldersMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    shoulderCircumference: shoulderCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension ShouldersMeasurementEntry {
    static var mocks: [ShouldersMeasurementEntry] {
        [
            ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), shoulderCircumference: 45.6),
            ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), shoulderCircumference: 45.4),
            ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), shoulderCircumference: 45.2),
            ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), shoulderCircumference: 45.1),
            ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), shoulderCircumference: 45.0),
            ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), shoulderCircumference: 44.9),
            ShouldersMeasurementEntry(date: Date.now, shoulderCircumference: 44.8)
        ]
    }
}

extension CoreRouter {
    func showShouldersMeasurementView(delegate: ShouldersMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.shouldersMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func shouldersMeasurementView(router: Router, delegate: ShouldersMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: ShouldersMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
