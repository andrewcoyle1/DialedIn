import SwiftUI

struct LeftBicepMeasurementDelegate {

}

struct LeftBicepMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftBicepCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftBicepCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftBicepCircumference = leftBicepCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftBicepCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Bicep", date: date, value: leftBicepCircumference)]
    }
}

@Observable
@MainActor
final class LeftBicepMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftBicepMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftBicepMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftBicepCircumference) }
        return [TimeSeries(name: "Left Bicep Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Bicep Circumference",
            analyticsName: "LeftBicepMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Left Bicep Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left bicep measurement entries",
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftBicepMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.leftBicepEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogMeasurementView(kind: .leftBicep)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: LeftBicepMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftBicepCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.leftBicepEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func leftBicepEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [LeftBicepMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftBicepCircumference = entry.leftBicepCircumference else { return nil }
                return LeftBicepMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftBicepCircumference: UnitConversion.convertLength(leftBicepCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftBicepMeasurementEntry {
    static let mocks: [LeftBicepMeasurementEntry] = [
        LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftBicepCircumference: 14.6),
        LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftBicepCircumference: 14.4),
        LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftBicepCircumference: 14.2),
        LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftBicepCircumference: 14.1),
        LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftBicepCircumference: 14.0),
        LeftBicepMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftBicepCircumference: 13.9),
        LeftBicepMeasurementEntry(date: Date.now, leftBicepCircumference: 13.8)
    ]
}

extension CoreRouter {
    func showLeftBicepMeasurementView(delegate: LeftBicepMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.leftBicepMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func leftBicepMeasurementView(router: AnyRouter, delegate: LeftBicepMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: LeftBicepMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
