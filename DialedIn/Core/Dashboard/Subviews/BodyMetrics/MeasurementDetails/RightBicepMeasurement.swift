import SwiftUI

struct RightBicepMeasurementDelegate {

}

struct RightBicepMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightBicepCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightBicepCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightBicepCircumference = rightBicepCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightBicepCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Bicep", date: date, value: rightBicepCircumference)]
    }
}

@Observable
@MainActor
final class RightBicepMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = RightBicepMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightBicepMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightBicepCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Right Bicep Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Bicep Circumference",
            analyticsName: "RightBicepMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Right Bicep Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right bicep measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [RightBicepMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightBicepEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogRightBicepMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: RightBicepMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightBicepCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightBicepEntries(from: localEntries)
    }

    private static func rightBicepEntries(from entries: [BodyMeasurementEntry]) -> [RightBicepMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightBicepCircumference = entry.rightBicepCircumference else { return nil }
                return RightBicepMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightBicepCircumference: rightBicepCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightBicepMeasurementEntry {
    static var mocks: [RightBicepMeasurementEntry] {
        [
            RightBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightBicepCircumference: 14.6),
            RightBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightBicepCircumference: 14.4),
            RightBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightBicepCircumference: 14.2),
            RightBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightBicepCircumference: 14.1),
            RightBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightBicepCircumference: 14.0),
            RightBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightBicepCircumference: 13.9),
            RightBicepMeasurementEntry(date: Date.now, rightBicepCircumference: 13.8)
        ]
    }
}

extension CoreRouter {
    func showRightBicepMeasurementView(delegate: RightBicepMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.rightBicepMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func rightBicepMeasurementView(router: Router, delegate: RightBicepMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: RightBicepMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
