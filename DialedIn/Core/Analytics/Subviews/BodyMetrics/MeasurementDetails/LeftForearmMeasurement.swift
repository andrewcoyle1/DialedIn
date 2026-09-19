import SwiftUI

struct LeftForearmMeasurementDelegate {

}

struct LeftForearmMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftForearmCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftForearmCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftForearmCircumference = leftForearmCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftForearmCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Forearm", date: date, value: leftForearmCircumference)]
    }
}

@Observable
@MainActor
final class LeftForearmMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftForearmMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftForearmMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftForearmCircumference) }
        return [TimeSeries(name: "Left Forearm Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Forearm Circumference",
            analyticsName: "LeftForearmMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Left Forearm Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left forearm measurement entries",
            pageSize: 20,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftForearmMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.leftForearmEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogLeftForearmMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: LeftForearmMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftForearmCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.leftForearmEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func leftForearmEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [LeftForearmMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftForearmCircumference = entry.leftForearmCircumference else { return nil }
                return LeftForearmMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftForearmCircumference: UnitConversion.convertLength(leftForearmCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftForearmMeasurementEntry {
    static let mocks: [LeftForearmMeasurementEntry] = [
        LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftForearmCircumference: 12.6),
        LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftForearmCircumference: 12.4),
        LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftForearmCircumference: 12.2),
        LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftForearmCircumference: 12.1),
        LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftForearmCircumference: 12.0),
        LeftForearmMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftForearmCircumference: 11.9),
        LeftForearmMeasurementEntry(date: Date.now, leftForearmCircumference: 11.8)
    ]
}

extension CoreRouter {
    func showLeftForearmMeasurementView(delegate: LeftForearmMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.leftForearmMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func leftForearmMeasurementView(router: AnyRouter, delegate: LeftForearmMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: LeftForearmMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
