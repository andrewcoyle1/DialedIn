import SwiftUI

struct VisualBodyFatDelegate {

}

struct VisualBodyFatEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let bodyFatPercent: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        bodyFatPercent: Double
    ) {
        self.id = id
        self.date = date
        self.bodyFatPercent = bodyFatPercent
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        bodyFatPercent.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "percent"
    }

    func timeSeriesData() -> [(seriesName: String, date: Date, value: Double)] {
        [("Body Fat", date, bodyFatPercent)]
    }
}

@Observable
@MainActor
final class VisualBodyFatPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = VisualBodyFatEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [VisualBodyFatEntry]

    var timeSeries: [TimeSeriesData.TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.bodyFatPercent) }
        return [TimeSeriesData.TimeSeries(name: "Body Fat", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Visual Body Fat",
            analyticsName: "VisualBodyFatView",
            yAxisSuffix: " %",
            seriesNames: ["Body Fat"],
            showsAddButton: false,
            sectionHeader: "Entries",
            emptyStateMessage: "No body fat entries",
            pageSize: nil
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [VisualBodyFatEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        await interactor.backfillBodyFatFromHealthKit()
        let localEntries = (try? interactor.readAllLocalWeightEntries()) ?? interactor.weightHistory
        entries = Self.bodyFatEntries(from: localEntries)
    }

    func onAddPressed() {
        // No-op until data entry flow is available
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    private static func bodyFatEntries(from weightEntries: [WeightEntry]) -> [VisualBodyFatEntry] {
        weightEntries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let bodyFatPercentage = entry.bodyFatPercentage else { return nil }
                return VisualBodyFatEntry(
                    id: entry.id,
                    date: entry.date,
                    bodyFatPercent: bodyFatPercentage
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension VisualBodyFatEntry {
    static var mocks: [VisualBodyFatEntry] {
        [
            VisualBodyFatEntry(date: Date.now.addingTimeInterval(-86400 * 6), bodyFatPercent: 15.6),
            VisualBodyFatEntry(date: Date.now.addingTimeInterval(-86400 * 5), bodyFatPercent: 15.4),
            VisualBodyFatEntry(date: Date.now.addingTimeInterval(-86400 * 4), bodyFatPercent: 15.2),
            VisualBodyFatEntry(date: Date.now.addingTimeInterval(-86400 * 3), bodyFatPercent: 15.1),
            VisualBodyFatEntry(date: Date.now.addingTimeInterval(-86400 * 2), bodyFatPercent: 15.0),
            VisualBodyFatEntry(date: Date.now.addingTimeInterval(-86400 * 1), bodyFatPercent: 14.9),
            VisualBodyFatEntry(date: Date.now, bodyFatPercent: 14.8)
        ]
    }
}

extension CoreRouter {
    func showVisualBodyFatView(delegate: VisualBodyFatDelegate) {
        router.showScreen(.sheet) { router in
            builder.visualBodyFatView(router: router, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func visualBodyFatView(router: Router, delegate: VisualBodyFatDelegate) -> some View {
        MetricDetailView(
            presenter: VisualBodyFatPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
