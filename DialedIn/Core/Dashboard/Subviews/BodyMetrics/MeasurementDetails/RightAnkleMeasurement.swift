import SwiftUI

struct RightAnkleMeasurementDelegate {

}

struct RightAnkleMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightAnkleCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightAnkleCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightAnkleCircumference = rightAnkleCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightAnkleCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Ankle", date: date, value: rightAnkleCircumference)]
    }
}

@Observable
@MainActor
final class RightAnkleMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = RightAnkleMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightAnkleMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightAnkleCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Right Ankle Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Ankle Circumference",
            analyticsName: "RightAnkleMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Right Ankle Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right ankle measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [RightAnkleMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightAnkleEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogRightAnkleMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: RightAnkleMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightAnkleCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightAnkleEntries(from: localEntries)
    }

    private static func rightAnkleEntries(from entries: [BodyMeasurementEntry]) -> [RightAnkleMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightAnkleCircumference = entry.rightAnkleCircumference else { return nil }
                return RightAnkleMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightAnkleCircumference: rightAnkleCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightAnkleMeasurementEntry {
    static var mocks: [RightAnkleMeasurementEntry] {
        [
            RightAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightAnkleCircumference: 9.0),
            RightAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightAnkleCircumference: 8.9),
            RightAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightAnkleCircumference: 8.8),
            RightAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightAnkleCircumference: 8.7),
            RightAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightAnkleCircumference: 8.6),
            RightAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightAnkleCircumference: 8.5),
            RightAnkleMeasurementEntry(date: Date.now, rightAnkleCircumference: 8.4)
        ]
    }
}

extension CoreRouter {
    func showRightAnkleMeasurementView(delegate: RightAnkleMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.rightAnkleMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func rightAnkleMeasurementView(router: Router, delegate: RightAnkleMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: RightAnkleMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
