//
//  FoodLoggingConsistencyPresenter.swift
//  DialedIn
//

import SwiftUI

@Observable
@MainActor
final class FoodLoggingConsistencyPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = NutritionMetricEntry

    private let interactor: NutritionAnalyticsInteractor
    private let router: NutritionAnalyticsRouter
    private let calendar = Calendar.current

    private(set) var entries: [NutritionMetricEntry] = []

    init(interactor: NutritionAnalyticsInteractor, router: NutritionAnalyticsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onAppear() async {
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .year, value: -1, to: endDate) else { return }
        let startDayKey = calendar.startOfDay(for: startDate).dayKey
        let endDayKey = calendar.startOfDay(for: endDate).dayKey

        let totalsData = (try? interactor.getDailyTotals(startDayKey: startDayKey, endDayKey: endDayKey)) ?? []
        var newEntries: [NutritionMetricEntry] = []
        for item in totalsData {
            let total = item.totals.proteinGrams + item.totals.carbGrams + item.totals.fatGrams
            guard total > 0, let date = Date(dayKey: item.dayKey) else { continue }
            newEntries.append(NutritionMetricEntry(
                id: item.dayKey,
                date: date,
                value: item.totals.calories,
                metric: .calories
            ))
        }
        entries = newEntries.sorted { $0.date < $1.date }
    }

    var timeSeries: [TimeSeriesData.TimeSeries] { [] }

    var contributionChartData: [Double]? {
        let foodLoggedDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
        let endDate = calendar.startOfDay(for: Date())
        let totalDays = 3 * 10
        guard let chartStartDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) else { return nil }
        var data = Array(repeating: 0.0, count: 30)
        for column in 0..<10 {
            for row in 0..<3 {
                let dayOffset = column * 3 + row
                guard let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: chartStartDate),
                      dayOffset < 30 else { continue }
                if foodLoggedDates.contains(calendar.startOfDay(for: cellDate)) {
                    data[dayOffset] = 1.0
                }
            }
        }
        return data
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Food Logging",
            analyticsName: "FoodLoggingConsistencyView",
            yAxisSuffix: " kcal",
            seriesNames: ["Food Logged"],
            showsAddButton: false,
            sectionHeader: "Days Logged",
            emptyStateMessage: "No food logged. Log meals to see your consistency.",
            pageSize: 20,
            chartColor: .orange
        )
    }

    func onAddPressed() {}

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: NutritionMetricEntry) async {
        // Entries are derived from meals; deletion not supported at this level
    }
}
