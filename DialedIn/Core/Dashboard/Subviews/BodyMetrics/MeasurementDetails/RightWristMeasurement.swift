import SwiftUI

struct RightWristMeasurementDelegate {

}

struct RightWristMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightWristCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightWristCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightWristCircumference = rightWristCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightWristCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Wrist", date: date, value: rightWristCircumference)]
    }
}

@Observable
@MainActor
final class RightWristMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = RightWristMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightWristMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightWristCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Right Wrist Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Wrist Circumference",
            analyticsName: "RightWristMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Right Wrist Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right wrist measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [RightWristMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightWristEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogRightWristMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: RightWristMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightWristCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.rightWristEntries(from: localEntries)
    }

    private static func rightWristEntries(from entries: [BodyMeasurementEntry]) -> [RightWristMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightWristCircumference = entry.rightWristCircumference else { return nil }
                return RightWristMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightWristCircumference: rightWristCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightWristMeasurementEntry {
    static var mocks: [RightWristMeasurementEntry] {
        [
            RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightWristCircumference: 7.0),
            RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightWristCircumference: 6.9),
            RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightWristCircumference: 6.8),
            RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightWristCircumference: 6.7),
            RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightWristCircumference: 6.6),
            RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightWristCircumference: 6.5),
            RightWristMeasurementEntry(date: Date.now, rightWristCircumference: 6.4)
        ]
    }
}

extension CoreRouter {
    func showRightWristMeasurementView(delegate: RightWristMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.rightWristMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func rightWristMeasurementView(router: Router, delegate: RightWristMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: RightWristMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
