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

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftAnkleCircumference) }
        return [TimeSeries(name: "Left Ankle Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Ankle Circumference",
            analyticsName: "LeftAnkleMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Left Ankle Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left ankle measurement entries",
            pageSize: 20,
            chartColor: .green
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
        entries = Self.leftAnkleEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogLeftAnkleMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: LeftAnkleMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftAnkleCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.leftAnkleEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func leftAnkleEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [LeftAnkleMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftAnkleCircumference = entry.leftAnkleCircumference else { return nil }
                return LeftAnkleMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftAnkleCircumference: UnitConversion.convertLength(leftAnkleCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftAnkleMeasurementEntry {
    static let mocks: [LeftAnkleMeasurementEntry] = [
        LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftAnkleCircumference: 9.0),
        LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftAnkleCircumference: 8.9),
        LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftAnkleCircumference: 8.8),
        LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftAnkleCircumference: 8.7),
        LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftAnkleCircumference: 8.6),
        LeftAnkleMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftAnkleCircumference: 8.5),
        LeftAnkleMeasurementEntry(date: Date.now, leftAnkleCircumference: 8.4)
    ]
}

extension CoreRouter {
    func showLeftAnkleMeasurementView(delegate: LeftAnkleMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.leftAnkleMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func leftAnkleMeasurementView(router: AnyRouter, delegate: LeftAnkleMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: LeftAnkleMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
