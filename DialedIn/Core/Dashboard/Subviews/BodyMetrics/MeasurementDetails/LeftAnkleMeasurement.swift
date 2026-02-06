import SwiftUI

struct LeftAnkleMeasurementDelegate {

}

struct LeftAnkleMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftAnkleCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftAnkleCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftAnkleCircumference = leftAnkleCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftAnkleCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Ankle", date: date, value: leftAnkleCircumference)]
    }
}

@Observable
@MainActor
final class LeftAnkleMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftAnkleMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftAnkleMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftAnkleCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Left Ankle Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Ankle Circumference",
            analyticsName: "LeftAnkleMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Left Ankle Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left ankle measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftAnkleMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftAnkleEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogLeftAnkleMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: LeftAnkleMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftAnkleCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftAnkleEntries(from: localEntries)
    }

    private static func leftAnkleEntries(from entries: [BodyMeasurementEntry]) -> [LeftAnkleMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftAnkleCircumference = entry.leftAnkleCircumference else { return nil }
                return LeftAnkleMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftAnkleCircumference: leftAnkleCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftAnkleMeasurementEntry {
    static var mocks: [LeftAnkleMeasurementEntry] {
        [
            LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftAnkleCircumference: 9.0),
            LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftAnkleCircumference: 8.9),
            LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftAnkleCircumference: 8.8),
            LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftAnkleCircumference: 8.7),
            LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftAnkleCircumference: 8.6),
            LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftAnkleCircumference: 8.5),
            LeftAnkleMeasurementEntry(date: Date.now, leftAnkleCircumference: 8.4)
        ]
    }
}

extension CoreRouter {
    func showLeftAnkleMeasurementView(delegate: LeftAnkleMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.leftAnkleMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func leftAnkleMeasurementView(router: Router, delegate: LeftAnkleMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: LeftAnkleMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
