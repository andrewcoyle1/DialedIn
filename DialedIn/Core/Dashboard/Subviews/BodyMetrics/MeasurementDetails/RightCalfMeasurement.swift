import SwiftUI

struct RightCalfMeasurementDelegate {

}

struct RightCalfMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightCalfCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightCalfCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightCalfCircumference = rightCalfCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightCalfCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Calf", date: date, value: rightCalfCircumference)]
    }
}

@Observable
@MainActor
final class RightCalfMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = RightCalfMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightCalfMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightCalfCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Right Calf Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Calf Circumference",
            analyticsName: "RightCalfMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Right Calf Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right calf measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [RightCalfMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightCalfEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogRightCalfMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: RightCalfMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightCalfCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightCalfEntries(from: localEntries)
    }

    private static func rightCalfEntries(from entries: [BodyMeasurementEntry]) -> [RightCalfMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightCalfCircumference = entry.rightCalfCircumference else { return nil }
                return RightCalfMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightCalfCircumference: rightCalfCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightCalfMeasurementEntry {
    static var mocks: [RightCalfMeasurementEntry] {
        [
            RightCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightCalfCircumference: 15.6),
            RightCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightCalfCircumference: 15.4),
            RightCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightCalfCircumference: 15.2),
            RightCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightCalfCircumference: 15.1),
            RightCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightCalfCircumference: 15.0),
            RightCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightCalfCircumference: 14.9),
            RightCalfMeasurementEntry(date: Date.now, rightCalfCircumference: 14.8)
        ]
    }
}

extension CoreRouter {
    func showRightCalfMeasurementView(delegate: RightCalfMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.rightCalfMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func rightCalfMeasurementView(router: Router, delegate: RightCalfMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: RightCalfMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
