import SwiftUI

struct LeftWristMeasurementDelegate {

}

struct LeftWristMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftWristCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftWristCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftWristCircumference = leftWristCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftWristCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Wrist", date: date, value: leftWristCircumference)]
    }
}

@Observable
@MainActor
final class LeftWristMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftWristMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftWristMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftWristCircumference) }
        return [TimeSeries(name: "Left Wrist Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Wrist Circumference",
            analyticsName: "LeftWristMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Left Wrist Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left wrist measurement entries",
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftWristMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.leftWristEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogLeftWristMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: LeftWristMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftWristCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.leftWristEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func leftWristEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [LeftWristMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftWristCircumference = entry.leftWristCircumference else { return nil }
                return LeftWristMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftWristCircumference: UnitConversion.convertLength(leftWristCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftWristMeasurementEntry {
    static let mocks: [LeftWristMeasurementEntry] = [
        LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftWristCircumference: 7.0),
        LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftWristCircumference: 6.9),
        LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftWristCircumference: 6.8),
        LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftWristCircumference: 6.7),
        LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftWristCircumference: 6.6),
        LeftWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftWristCircumference: 6.5),
        LeftWristMeasurementEntry(date: Date.now, leftWristCircumference: 6.4)
    ]
}

extension CoreRouter {
    func showLeftWristMeasurementView(delegate: LeftWristMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.leftWristMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func leftWristMeasurementView(router: AnyRouter, delegate: LeftWristMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: LeftWristMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
