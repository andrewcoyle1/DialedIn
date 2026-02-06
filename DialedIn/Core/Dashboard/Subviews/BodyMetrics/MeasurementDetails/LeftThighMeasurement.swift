import SwiftUI

struct LeftThighMeasurementDelegate {

}

struct LeftThighMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftThighCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftThighCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftThighCircumference = leftThighCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftThighCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Thigh", date: date, value: leftThighCircumference)]
    }
}

@Observable
@MainActor
final class LeftThighMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftThighMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftThighMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftThighCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Left Thigh Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Thigh Circumference",
            analyticsName: "LeftThighMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Left Thigh Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left thigh measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftThighMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftThighEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogLeftThighMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: LeftThighMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftThighCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftThighEntries(from: localEntries)
    }

    private static func leftThighEntries(from entries: [BodyMeasurementEntry]) -> [LeftThighMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftThighCircumference = entry.leftThighCircumference else { return nil }
                return LeftThighMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftThighCircumference: leftThighCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftThighMeasurementEntry {
    static var mocks: [LeftThighMeasurementEntry] {
        [
            LeftThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftThighCircumference: 24.6),
            LeftThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftThighCircumference: 24.4),
            LeftThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftThighCircumference: 24.2),
            LeftThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftThighCircumference: 24.1),
            LeftThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftThighCircumference: 24.0),
            LeftThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftThighCircumference: 23.9),
            LeftThighMeasurementEntry(date: Date.now, leftThighCircumference: 23.8)
        ]
    }
}

extension CoreRouter {
    func showLeftThighMeasurementView(delegate: LeftThighMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.leftThighMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func leftThighMeasurementView(router: Router, delegate: LeftThighMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: LeftThighMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
