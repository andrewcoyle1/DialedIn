import SwiftUI

struct LeftForearmMeasurementDelegate {

}

struct LeftForearmMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftForearmCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftForearmCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftForearmCircumference = leftForearmCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftForearmCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Forearm", date: date, value: leftForearmCircumference)]
    }
}

@Observable
@MainActor
final class LeftForearmMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftForearmMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftForearmMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftForearmCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Left Forearm Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Forearm Circumference",
            analyticsName: "LeftForearmMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Left Forearm Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left forearm measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftForearmMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftForearmEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogLeftForearmMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: LeftForearmMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftForearmCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftForearmEntries(from: localEntries)
    }

    private static func leftForearmEntries(from entries: [BodyMeasurementEntry]) -> [LeftForearmMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftForearmCircumference = entry.leftForearmCircumference else { return nil }
                return LeftForearmMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftForearmCircumference: leftForearmCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftForearmMeasurementEntry {
    static var mocks: [LeftForearmMeasurementEntry] {
        [
            LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftForearmCircumference: 12.6),
            LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftForearmCircumference: 12.4),
            LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftForearmCircumference: 12.2),
            LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftForearmCircumference: 12.1),
            LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftForearmCircumference: 12.0),
            LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftForearmCircumference: 11.9),
            LeftForearmMeasurementEntry(date: Date.now, leftForearmCircumference: 11.8)
        ]
    }
}

extension CoreRouter {
    func showLeftForearmMeasurementView(delegate: LeftForearmMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.leftForearmMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func leftForearmMeasurementView(router: Router, delegate: LeftForearmMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: LeftForearmMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
