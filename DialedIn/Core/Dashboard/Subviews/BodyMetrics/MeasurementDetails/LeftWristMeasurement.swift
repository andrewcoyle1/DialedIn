import SwiftUI

struct LeftWristMeasurementDelegate {

}

struct LeftWristMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftWristCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftWristCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftWristCircumference = leftWristCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftWristCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Wrist", date: date, value: leftWristCircumference)]
    }
}

@Observable
@MainActor
final class LeftWristMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftWristMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftWristMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftWristCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Left Wrist Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Wrist Circumference",
            analyticsName: "LeftWristMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Left Wrist Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left wrist measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftWristMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftWristEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogLeftWristMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: LeftWristMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftWristCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftWristEntries(from: localEntries)
    }

    private static func leftWristEntries(from entries: [BodyMeasurementEntry]) -> [LeftWristMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftWristCircumference = entry.leftWristCircumference else { return nil }
                return LeftWristMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftWristCircumference: leftWristCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftWristMeasurementEntry {
    static var mocks: [LeftWristMeasurementEntry] {
        [
            LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftWristCircumference: 7.0),
            LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftWristCircumference: 6.9),
            LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftWristCircumference: 6.8),
            LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftWristCircumference: 6.7),
            LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftWristCircumference: 6.6),
            LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftWristCircumference: 6.5),
            LeftWristMeasurementEntry(date: Date.now, leftWristCircumference: 6.4)
        ]
    }
}

extension CoreRouter {
    func showLeftWristMeasurementView(delegate: LeftWristMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.leftWristMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func leftWristMeasurementView(router: Router, delegate: LeftWristMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: LeftWristMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
