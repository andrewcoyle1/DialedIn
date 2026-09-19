import SwiftUI

struct LeftCalfMeasurementDelegate {

}

struct LeftCalfMeasurementEntry: @MainActor MetricEntry {
    let id: String
    let date: Date
    let leftCalfCircumference: Double

    init(
        id: String = UUID().uuidString,
        date: Date,
        leftCalfCircumference: Double
    ) {
        self.id = id
        self.date = date
        self.leftCalfCircumference = leftCalfCircumference
    }

    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        leftCalfCircumference.formatted(.number.precision(.fractionLength(1)))
    }

    var systemImageName: String {
        "figure.walk"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Left Calf", date: date, value: leftCalfCircumference)]
    }
}

@Observable
@MainActor
final class LeftCalfMeasurementPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = LeftCalfMeasurementEntry

    private let interactor: BodyMetricsInteractor
    private let router: BodyMetricsRouter

    var entries: [LeftCalfMeasurementEntry]

    var timeSeries: [TimeSeries] {
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.leftCalfCircumference) }
        return [TimeSeries(name: "Left Calf Circumference", data: data)]
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Left Calf Circumference",
            analyticsName: "LeftCalfMeasurementView",
            yAxisSuffix: " \(interactor.lengthUnitPreference.measurementAbbreviation)",
            seriesNames: ["Left Calf Circumference"],
            showsAddButton: true,
            sectionHeader: "Entries",
            emptyStateMessage: "No left calf measurement entries",
            pageSize: 20,
            chartColor: .green
        )
    }

    init(
        interactor: BodyMetricsInteractor,
        router: BodyMetricsRouter,
        entries: [LeftCalfMeasurementEntry] = []
    ) {
        self.interactor = interactor
        self.router = router
        self.entries = entries.sorted { $0.date < $1.date }
    }

    func onAppear() async {
        entries = Self.leftCalfEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    func onAddPressed() {
        router.showLogLeftCalfMeasurementView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: LeftCalfMeasurementEntry) async {
        guard let baseEntry = interactor.bodyMeasurements.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = baseEntry.withCleared(.leftCalfCircumference)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        entries = Self.leftCalfEntries(from: interactor.bodyMeasurements, unit: interactor.lengthUnitPreference)
    }

    /// Values are converted here, once, so `displayValue` and the chart agree with the
    /// suffix in `configuration`.
    private static func leftCalfEntries(from entries: [BodyMeasurementEntry], unit: LengthUnitPreference) -> [LeftCalfMeasurementEntry] {
        entries
            .filter { $0.deletedAt == nil }
            .compactMap { entry in
                guard let leftCalfCircumference = entry.leftCalfCircumference else { return nil }
                return LeftCalfMeasurementEntry(
                    id: entry.id,
                    date: entry.date,
                    leftCalfCircumference: UnitConversion.convertLength(leftCalfCircumference, to: unit)
                )
            }
            .sorted { $0.date < $1.date }
    }
}

extension LeftCalfMeasurementEntry {
    static let mocks: [LeftCalfMeasurementEntry] = [
        LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 6), leftCalfCircumference: 15.6),
        LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 5), leftCalfCircumference: 15.4),
        LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 4), leftCalfCircumference: 15.2),
        LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 3), leftCalfCircumference: 15.1),
        LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 2), leftCalfCircumference: 15.0),
        LeftCalfMeasurementEntry(date: Date.now.addingTimeInterval(-86400 * 1), leftCalfCircumference: 14.9),
        LeftCalfMeasurementEntry(date: Date.now, leftCalfCircumference: 14.8)
    ]
}

extension CoreRouter {
    func showLeftCalfMeasurementView(delegate: LeftCalfMeasurementDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.leftCalfMeasurementView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}

extension CoreBuilder {
    func leftCalfMeasurementView(router: AnyRouter, delegate: LeftCalfMeasurementDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: LeftCalfMeasurementPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}
