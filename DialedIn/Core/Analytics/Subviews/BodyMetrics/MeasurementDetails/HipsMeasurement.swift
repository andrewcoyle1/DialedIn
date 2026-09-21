import SwiftUI

struct HipsMeasurementDelegate {

}

struct HipsMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let hipCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        hipCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.hipCircumference = hipCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        hipCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Hips", date: date, value: hipCircumference)]
    }
}

@Observable
@MainActor
final class HipsMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = HipsMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [HipsMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.hipCircumference) }
        return [TimeSeries(name: "Hips Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Hips Circumference",
            analyticsName: "HipsMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Hips Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No hips measurement entries",
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [HipsMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.hipsEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogMeasurementView(kind: .hips)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: HipsMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.hipCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.hipsEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func hipsEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [HipsMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let hipCircumference = entry.hipCircumference else { return nil }
                return HipsMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    hipCircumference: UnitConversion.convertLength(hipCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension HipsMeasurementEntry {
    static let mocks: [HipsMeasurementEntry] = [
        HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), hipCircumference: 38.6),
        HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), hipCircumference: 38.4),
        HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), hipCircumference: 38.2),
        HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), hipCircumference: 38.1),
        HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), hipCircumference: 38.0),
        HipsMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), hipCircumference: 37.9),
        HipsMeasurementEntry(date: Date.now, hipCircumference: 37.8)
    ]
}

extension CoreRouter {
    func showHipsMeasurementView(delegate: HipsMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.hipsMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func hipsMeasurementView(router: AnyRouter, delegate: HipsMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: HipsMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
