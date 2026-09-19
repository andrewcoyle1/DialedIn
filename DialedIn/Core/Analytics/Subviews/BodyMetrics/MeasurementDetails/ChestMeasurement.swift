import SwiftUI

struct ChestMeasurementDelegate {

}

struct ChestMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let chestCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        chestCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.chestCircumference = chestCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        chestCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Chest", date: date, value: chestCircumference)]
    }
}

@Observable
@MainActor
final class ChestMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ChestMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [ChestMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.chestCircumference) }
        return [TimeSeries(name: "Chest Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Chest Circumference",
            analyticsName: "ChestMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Chest Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No chest measurement entries",
            pageSize: 20,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [ChestMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.chestEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogChestMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: ChestMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.chestCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.chestEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func chestEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [ChestMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let chestCircumference = entry.chestCircumference else { return nil }
                return ChestMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    chestCircumference: UnitConversion.convertLength(chestCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension ChestMeasurementEntry {
    static let mocks: [ChestMeasurementEntry] = [
        ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), chestCircumference: 42.6),
        ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), chestCircumference: 42.4),
        ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), chestCircumference: 42.2),
        ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), chestCircumference: 42.1),
        ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), chestCircumference: 42.0),
        ChestMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), chestCircumference: 41.9),
        ChestMeasurementEntry(date: Date.now, chestCircumference: 41.8)
    ]
}

extension CoreRouter {
    func showChestMeasurementView(delegate: ChestMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.chestMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func chestMeasurementView(router: AnyRouter, delegate: ChestMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: ChestMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
