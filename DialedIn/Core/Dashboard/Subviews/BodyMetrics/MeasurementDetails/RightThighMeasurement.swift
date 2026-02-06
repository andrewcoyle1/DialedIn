import SwiftUI

struct RightThighMeasurementDelegate {

}

struct RightThighMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightThighCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightThighCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightThighCircumference = rightThighCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightThighCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Thigh", date: date, value: rightThighCircumference)]
    }
}

@Observable
@MainActor
final class RightThighMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = RightThighMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightThighMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightThighCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Right Thigh Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Thigh Circumference",
            analyticsName: "RightThighMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Right Thigh Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right thigh measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [RightThighMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightThighEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogRightThighMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: RightThighMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightThighCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightThighEntries(from: localEntries)
    }

    private static func rightThighEntries(from entries: [BodyMeasurementEntry]) -> [RightThighMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightThighCircumference = entry.rightThighCircumference else { return nil }
                return RightThighMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightThighCircumference: rightThighCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightThighMeasurementEntry {
    static var mocks: [RightThighMeasurementEntry] {
        [
            RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightThighCircumference: 24.6),
            RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightThighCircumference: 24.4),
            RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightThighCircumference: 24.2),
            RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightThighCircumference: 24.1),
            RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightThighCircumference: 24.0),
            RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightThighCircumference: 23.9),
            RightThighMeasurementEntry(date: Date.now, rightThighCircumference: 23.8)
        ]
    }
}

extension CoreRouter {
    func showRightThighMeasurementView(delegate: RightThighMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.rightThighMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func rightThighMeasurementView(router: Router, delegate: RightThighMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: RightThighMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
