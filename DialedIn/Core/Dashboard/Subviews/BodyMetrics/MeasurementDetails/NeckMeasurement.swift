import SwiftUI

struct NeckMeasurementDelegate {

}

struct NeckMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let neckCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        neckCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.neckCircumference = neckCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        neckCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "percent"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Body Fat", date: date, value: neckCircumference)]
    }
}

@Observable
@MainActor
final class NeckMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = NeckMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [NeckMeasurementEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.neckCircumference) }
        return [TimeSeriesData.TimeSeries(name: "Neck Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Neck Circumference",
            analyticsName: "NeckMeasurementView",
            yAxisSuffix: " cm",
            seriesNames: ["Neck Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No neck measurement entries",
            pageSize: nil,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [NeckMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        await interactor.backfillBodyFatFromHealthKit()
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.bodyFatEntries(from: localEntries)
    }

    func onAddPressed() {
        router.showLogNeckMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: NeckMeasurementEntry) async {
        guard let baseEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.neckCircumference)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.measurementHistory
        entries = Self.bodyFatEntries(from: localEntries)
    }

    private static func bodyFatEntries(from weightEntries: [BodyMeasurementEntry]) -> [NeckMeasurementEntry] {
        weightEntries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let neckCircumference = entry.neckCircumference else { return nil }
                return NeckMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    neckCircumference: neckCircumference
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension NeckMeasurementEntry {
    static var mocks: [NeckMeasurementEntry] {
        [
            NeckMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), neckCircumference: 15.6),
            NeckMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), neckCircumference: 15.4),
            NeckMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), neckCircumference: 15.2),
            NeckMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), neckCircumference: 15.1),
            NeckMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), neckCircumference: 15.0),
            NeckMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), neckCircumference: 14.9),
            NeckMeasurementEntry(date: Date.now, neckCircumference: 14.8)
        ]
    }
}

extension CoreRouter {
    func showNeckMeasurementView(delegate: NeckMeasurementDelegate) {
        router.showScreen(.sheet) { router in
            builder.neckMeasurementView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func neckMeasurementView(router: Router, delegate: NeckMeasurementDelegate) -> some View {
        MetricDetailView(
            presenter: NeckMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
