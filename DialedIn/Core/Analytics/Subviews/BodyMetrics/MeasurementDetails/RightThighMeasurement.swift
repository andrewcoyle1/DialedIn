import SwiftUI

struct RightThighMeasurementDelegate {

}

struct RightThighMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightThighCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightThighCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightThighCircumference = rightThighCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightThighCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Thigh", date: date, value: rightThighCircumference)]
    }
}

@Observable
@MainActor
final class RightThighMeasurementPresenter: @MainActor MetricDetailPresenter {
    
    typealias Entry = RightThighMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightThighMeasurementEntry] {
        Self.rightThighEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
            .sorted { $0.date < $1.date }
    }

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightThighCircumference) }
        return [TimeSeries(name: "Right Thigh Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Thigh Circumference",
            analyticsName: "RightThighMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Right Thigh Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right thigh measurement entries",
            pageSize: 20,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    /// Nothing to load: unlike its siblings, `entries` is computed from `interactor.bodyMeasurements`
    /// on every read rather than cached, so it is already current.
    func onAppear() async { }

    func onAddPressed() {
        router.showLogRightThighMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: RightThighMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightThighCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func rightThighEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [RightThighMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightThighCircumference = entry.rightThighCircumference else { return nil }
                return RightThighMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightThighCircumference: UnitConversion.convertLength(rightThighCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightThighMeasurementEntry {
    static let mocks: [RightThighMeasurementEntry] = [
        RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightThighCircumference: 24.6),
        RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightThighCircumference: 24.4),
        RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightThighCircumference: 24.2),
        RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightThighCircumference: 24.1),
        RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightThighCircumference: 24.0),
        RightThighMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightThighCircumference: 23.9),
        RightThighMeasurementEntry(date: Date.now, rightThighCircumference: 23.8)
    ]
}

extension CoreRouter {
    func showRightThighMeasurementView(delegate: RightThighMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.rightThighMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func rightThighMeasurementView(router: AnyRouter, delegate: RightThighMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: RightThighMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
