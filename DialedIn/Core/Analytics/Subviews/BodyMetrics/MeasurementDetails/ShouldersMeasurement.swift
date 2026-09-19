import SwiftUI

struct ShouldersMeasurementDelegate {

}

struct ShouldersMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let shoulderCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        shoulderCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.shoulderCircumference = shoulderCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        shoulderCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Shoulders", date: date, value: shoulderCircumference)]
    }
}

@Observable
@MainActor
final class ShouldersMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ShouldersMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [ShouldersMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.shoulderCircumference) }
        return [TimeSeries(name: "Shoulders Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Shoulders Circumference",
            analyticsName: "ShouldersMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Shoulders Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No shoulders measurement entries",
            pageSize: 20,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [ShouldersMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.shouldersEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogShouldersMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: ShouldersMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.shoulderCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.shouldersEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func shouldersEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [ShouldersMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let shoulderCircumference = entry.shoulderCircumference else { return nil }
                return ShouldersMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    shoulderCircumference: UnitConversion.convertLength(shoulderCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension ShouldersMeasurementEntry {
    static let mocks: [ShouldersMeasurementEntry] = [
        ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), shoulderCircumference: 45.6),
        ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), shoulderCircumference: 45.4),
        ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), shoulderCircumference: 45.2),
        ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), shoulderCircumference: 45.1),
        ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), shoulderCircumference: 45.0),
        ShouldersMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), shoulderCircumference: 44.9),
        ShouldersMeasurementEntry(date: Date.now, shoulderCircumference: 44.8)
    ]
}

extension CoreRouter {
    func showShouldersMeasurementView(delegate: ShouldersMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.shouldersMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func shouldersMeasurementView(router: AnyRouter, delegate: ShouldersMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: ShouldersMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
