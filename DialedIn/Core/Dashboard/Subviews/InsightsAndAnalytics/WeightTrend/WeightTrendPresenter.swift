//
//  WeightTrendPresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class WeightTrendPresenter {

    private let interactor: WeightTrendInteractor
    private let router: WeightTrendRouter

    private(set) var cachedTrendEntries: [WeightTrendEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []

    var currentUser: UserModel? {
        interactor.currentUser
    }

    init(interactor: WeightTrendInteractor, router: WeightTrendRouter) {
        self.interactor = interactor
        self.router = router
        rebuildCaches()
    }

    func loadLocalWeightEntries() {
        do {
            _ = try interactor.readAllLocalWeightEntries()
            rebuildCaches()
        } catch {
            // No-op: remote load will run on first task.
        }
    }

    func readAllRemoteWeightEntries() async {
        guard let userId = currentUser?.userId else { return }
        do {
            _ = try await interactor.readAllRemoteWeightEntries(userId: userId)
            rebuildCaches()
        } catch {
            // Keep local data on failure.
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

        let scaleData = entries.compactMap { entry -> TimeSeriesDatapoint? in
            guard let weightKg = entry.weightKg else { return nil }
            return TimeSeriesDatapoint(id: entry.id, date: entry.date, value: weightKg)
        }

        let sortedEntries = entries.sorted { $0.date < $1.date }
        let sortedPairs = sortedEntries.compactMap { entry -> (date: Date, value: Double)? in
            guard let weightKg = entry.weightKg else { return nil }
            return (date: entry.date, value: weightKg)
        }

        let trendPairs = WeightTrendCalculator.exponentialMovingAverage(data: sortedPairs)

        cachedTrendEntries = zip(sortedEntries, trendPairs).map { entry, pair in
            WeightTrendEntry(id: entry.id, date: pair.date, trendValue: pair.value)
        }

        var series: [TimeSeriesData.TimeSeries] = [
            TimeSeriesData.TimeSeries(name: "Scale Weight", data: scaleData)
        ]

        if trendPairs.count >= 2 {
            let trendData = trendPairs.map { pair in
                TimeSeriesDatapoint(id: "trend-\(pair.date.timeIntervalSince1970)", date: pair.date, value: pair.value)
            }
            series.append(TimeSeriesData.TimeSeries(name: "Trend Weight", data: trendData))
        }

        cachedTimeSeries = series
    }
}

extension WeightTrendPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = WeightTrendEntry

    var entries: [WeightTrendEntry] {
        cachedTrendEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Weight Trend",
            analyticsName: "WeightTrendView",
            yAxisSuffix: " kg",
            seriesNames: ["Scale Weight", "Trend Weight"],
            showsAddButton: true,
            sectionHeader: "Trend History",
            emptyStateMessage: "No weight entries",
            pageSize: 20,
            chartColor: nil
        )
    }

    func onAppear() async {
        loadLocalWeightEntries()
    }

    func onAddPressed() {
        onAddWeightPressed()
    }

    func onDeleteEntry(_ entry: WeightTrendEntry) async {
        guard let bodyEntry = interactor.measurementHistory.first(where: { $0.id == entry.id }) else { return }
        let updatedEntry = bodyEntry.withCleared(.weightKg)
        try? await interactor.updateWeightEntry(entry: updatedEntry)
        _ = try? interactor.readAllLocalWeightEntries()
        rebuildCaches()
    }
}
