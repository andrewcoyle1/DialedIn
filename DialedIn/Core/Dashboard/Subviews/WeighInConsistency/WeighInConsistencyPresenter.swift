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
        do {
            _ = try interactor.readAllLocalWeightEntries()
            rebuildCaches()
        } catch {
            // No-op
        }
    }

    func onAddWeightPressed() {
        router.showLogWeightView()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    private func rebuildCaches() {
        let entries = interactor.measurementHistory.filter { $0.deletedAt == nil && $0.weightKg != nil }
        cachedEntries = entries
    }
}

extension WeighInConsistencyPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = BodyMeasurementEntry

    var entries: [BodyMeasurementEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
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
            yAxisSuffix: " kg",
            seriesNames: ["Weight"],
            showsAddButton: true,
            sectionHeader: "Weight Entries",
            emptyStateMessage: "No weigh-ins logged",
            pageSize: 20,
            chartColor: .green
        )
    }

    func onAppear() async {
        loadLocalWeightEntries()
    }

    func onAddPressed() {
        onAddWeightPressed()
    }

    func onDeleteEntry(_ entry: BodyMeasurementEntry) async {
        let updatedEntry = entry.withCleared(.weightKg)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        _ = try? interactor.readAllLocalWeightEntries()
        rebuildCaches()
    }
}
