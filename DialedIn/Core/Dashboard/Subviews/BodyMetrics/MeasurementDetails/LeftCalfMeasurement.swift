import SwiftUI

struct LeftCalfMeasurementDelegate {

}

struct LeftCalfMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftCalfCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftCalfCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftCalfCircumference = leftCalfCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftCalfCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Calf", date: date, value: leftCalfCircumference)]
    }
}

@Observable
@MainActor
final class LeftCalfMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftCalfMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftCalfMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftCalfCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Left Calf Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Calf Circumference",
            analyticsName: "LeftCalfMeasurementView",
            yAxisSuffix: " in",
            seriesNames: ["Left Calf Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left calf measurement entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftCalfMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftCalfEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogLeftCalfMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: LeftCalfMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftCalfCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.leftCalfEntries(from: localEntries)
    }

    private static func leftCalfEntries(from entries: [BodyMeasurementEntry]) -> [LeftCalfMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftCalfCircumference = entry.leftCalfCircumference else { return nil }
                return LeftCalfMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftCalfCircumference: leftCalfCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftCalfMeasurementEntry {
    static var mocks: [LeftCalfMeasurementEntry] {
        [
            LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftCalfCircumference: 15.6),
            LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftCalfCircumference: 15.4),
            LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftCalfCircumference: 15.2),
            LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftCalfCircumference: 15.1),
            LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftCalfCircumference: 15.0),
            LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftCalfCircumference: 14.9),
            LeftCalfMeasurementEntry(date: Date.now, leftCalfCircumference: 14.8)
        ]
    }
}

extension CoreRouter {
    func showLeftCalfMeasurementView(delegate: LeftCalfMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.leftCalfMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func leftCalfMeasurementView(router: Router, delegate: LeftCalfMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: LeftCalfMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
