import SwiftUI

struct RightForearmMeasurementDelegate {

}

struct RightForearmMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightForearmCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightForearmCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightForearmCircumference = rightForearmCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightForearmCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Forearm", date: date, value: rightForearmCircumference)]
    }
}

@Observable
@MainActor
final class RightForearmMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = RightForearmMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightForearmMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightForearmCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Right Forearm Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Forearm Circumference",
            analyticsName: "RightForearmMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Right Forearm Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right forearm measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [RightForearmMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightForearmEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogRightForearmMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: RightForearmMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightForearmCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightForearmEntries(from: localEntries)
    }

    private static func rightForearmEntries(from entries: [BodyMeasurementEntry]) -> [RightForearmMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightForearmCircumference = entry.rightForearmCircumference else { return nil }
                return RightForearmMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightForearmCircumference: rightForearmCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightForearmMeasurementEntry {
    static var mocks: [RightForearmMeasurementEntry] {
        [
            RightForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightForearmCircumference: 12.6),
            RightForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightForearmCircumference: 12.4),
            RightForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightForearmCircumference: 12.2),
            RightForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightForearmCircumference: 12.1),
            RightForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightForearmCircumference: 12.0),
            RightForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightForearmCircumference: 11.9),
            RightForearmMeasurementEntry(date: Date.now, rightForearmCircumference: 11.8)
        ]
    }
}

extension CoreRouter {
    func showRightForearmMeasurementView(delegate: RightForearmMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.rightForearmMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func rightForearmMeasurementView(router: Router, delegate: RightForearmMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: RightForearmMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
