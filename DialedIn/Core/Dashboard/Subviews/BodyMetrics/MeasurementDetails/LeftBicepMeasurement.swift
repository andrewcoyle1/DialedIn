import SwiftUI

struct LeftBicepMeasurementDelegate {

}

struct LeftBicepMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftBicepCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftBicepCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftBicepCircumference = leftBicepCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftBicepCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Bicep", date: date, value: leftBicepCircumference)]
    }
}

@Observable
@MainActor
final class LeftBicepMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftBicepMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftBicepMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftBicepCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Left Bicep Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Bicep Circumference",
            analyticsName: "LeftBicepMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Left Bicep Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left bicep measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftBicepMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftBicepEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogLeftBicepMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: LeftBicepMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftBicepCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftBicepEntries(from: localEntries)
    }

    private static func leftBicepEntries(from entries: [BodyMeasurementEntry]) -> [LeftBicepMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftBicepCircumference = entry.leftBicepCircumference else { return nil }
                return LeftBicepMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftBicepCircumference: leftBicepCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftBicepMeasurementEntry {
    static var mocks: [LeftBicepMeasurementEntry] {
        [
            LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftBicepCircumference: 14.6),
            LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftBicepCircumference: 14.4),
            LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftBicepCircumference: 14.2),
            LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftBicepCircumference: 14.1),
            LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftBicepCircumference: 14.0),
            LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftBicepCircumference: 13.9),
            LeftBicepMeasurementEntry(date: Date.now, leftBicepCircumference: 13.8)
        ]
    }
}

extension CoreRouter {
    func showLeftBicepMeasurementView(delegate: LeftBicepMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.leftBicepMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func leftBicepMeasurementView(router: Router, delegate: LeftBicepMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: LeftBicepMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
