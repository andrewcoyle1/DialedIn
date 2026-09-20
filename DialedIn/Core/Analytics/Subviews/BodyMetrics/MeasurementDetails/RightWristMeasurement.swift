import SwiftUI

struct RightWristMeasurementDelegate {

}

struct RightWristMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let rightWristCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        rightWristCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.rightWristCircumference = rightWristCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        rightWristCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.arms.open"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Right Wrist", date: date, value: rightWristCircumference)]
    }
}

@Observable
@MainActor
final class RightWristMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = RightWristMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [RightWristMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.rightWristCircumference) }
        return [TimeSeries(name: "Right Wrist Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Right Wrist Circumference",
            analyticsName: "RightWristMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Right Wrist Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No right wrist measurement entries",
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [RightWristMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.rightWristEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogRightWristMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: RightWristMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.rightWristCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.rightWristEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func rightWristEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [RightWristMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let rightWristCircumference = entry.rightWristCircumference else { return nil }
                return RightWristMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    rightWristCircumference: UnitConversion.convertLength(rightWristCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension RightWristMeasurementEntry {
    static let mocks: [RightWristMeasurementEntry] = [
        RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), rightWristCircumference: 7.0),
        RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), rightWristCircumference: 6.9),
        RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), rightWristCircumference: 6.8),
        RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), rightWristCircumference: 6.7),
        RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), rightWristCircumference: 6.6),
        RightWristMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), rightWristCircumference: 6.5),
        RightWristMeasurementEntry(date: Date.now, rightWristCircumference: 6.4)
    ]
}

extension CoreRouter {
    func showRightWristMeasurementView(delegate: RightWristMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.rightWristMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func rightWristMeasurementView(router: AnyRouter, delegate: RightWristMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: RightWristMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
