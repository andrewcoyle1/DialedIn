//
//  WeighInConsistencyPresenter.swift
//  DialedIn
//

import SwiftUI

@Observable
@MainActor
class WeighInConsistencyPresenter {

    private let interactor: ScaleWeightInteractor
    private let router: ScaleWeightRouter
    private let calendar = Calendar.current

    private(set) var cachedEntries: [BodyMeasurementEntry] = []

    init(interactor: ScaleWeightInteractor, router: ScaleWeightRouter) {
        self.interactor = interactor
        self.router = router
        rebuildCaches()
    }

    func loadLocalWeightEntries() {
        rebuildCaches()
    }

    func onAddWeightPressed() {
        router.showLogWeightView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    private func rebuildCaches() {
        let entries = interactor.bodyMeasurements.filter { $0.deletedAt == nil && $0.weightKg != nil }
        cachedEntries = entries
    }
}

extension WeighInConsistencyPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = BodyMeasurementEntry

    /// Weight is stored in kilograms; the card that opens this screen converts, and this screen
    /// hardcoded " kg".
    private var weightUnit: WeightUnitPreference {
        interactor.currentUser?.submittedWeightUnitPreference ?? .kilograms
    }

    func displayValue(for entry: BodyMeasurementEntry) -> String {
        guard let weightKg = entry.weightKg else { return "--" }
        return UnitConversion.formatWeight(weightKg, unit: weightUnit)
    }

    var entries: [BodyMeasurementEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeries] {
        []
    }

    var contributionChartData: [Double]? {
        let endDate = calendar.startOfDay(for: Date())
        let totalDays = 3 * 10
        guard let chartStartDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) else { return nil }
        let weighInDates = Set(cachedEntries.map { calendar.startOfDay(for: $0.date) })
        var data = Array(repeating: 0.0, count: 30)
        for column in 0..<10 {
            for row in 0..<3 {
                let dayOffset = column * 3 + row
                guard let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: chartStartDate),
                      dayOffset < 30 else { continue }
                if weighInDates.contains(calendar.startOfDay(for: cellDate)) {
                    data[dayOffset] = 1.0
                }
            }
        }
        return data
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Weigh In",
            analyticsName: "WeighInConsistencyView",
            yAxisSuffix: " \(weightUnit.abbreviation)",
            seriesNames: ["Weight"],
            showsAddButton: true,
            sectionHeader: "Weight Entries",
            emptyStateMessage: "No weigh-ins logged",
            chartColor: .green
        )
    }

    func onAppear() async {
        loadLocalWeightEntries()
    }

    func onAddPressed() {
        onAddWeightPressed()
    }

    var supportsDeletion: Bool { true }

    func onDeleteEntry(_ entry: BodyMeasurementEntry) async {
        let updatedEntry = entry.withCleared(.weightKg)
        do {
            try await interactor.saveBodyMeasurement(bodyMeasurement: updatedEntry)
        } catch {
            // Was `try?`. The refresh below re-reads unchanged data, so a failed delete put the row
            // straight back with nothing said about why.
            router.showSimpleAlert(title: "Unable to Delete Entry", subtitle: "Please try again.")
            return
        }
        rebuildCaches()
    }
}
