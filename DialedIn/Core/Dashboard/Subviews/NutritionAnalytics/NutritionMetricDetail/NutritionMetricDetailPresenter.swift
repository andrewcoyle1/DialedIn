//
//  NutritionMetricDetailPresenter.swift
//  DialedIn
//
//  Created by Cursor on 06/02/2026.
//

import SwiftUI

struct NutritionMetricDetailDelegate {}

@Observable
@MainActor
final class NutritionMetricDetailPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = NutritionMetricEntry

    private let interactor: NutritionAnalyticsInteractor
    private let router: NutritionAnalyticsRouter
    private let metric: NutritionMetric
    private let calendar = Calendar.current

    private(set) var entries: [NutritionMetricEntry] = []

    var contributionChartData: [Double]? {
        let endDate = calendar.startOfDay(for: Date())
        let totalDays = 3 * 10
        guard let chartStartDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) else { return nil }
        let loggedDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var data = Array(repeating: 0.0, count: 30)
        for column in 0..<10 {
            for row in 0..<3 {
                let dayOffset = column * 3 + row
                guard let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: chartStartDate),
                      dayOffset < 30 else { continue }
                if loggedDates.contains(calendar.startOfDay(for: cellDate)) {
                    data[dayOffset] = 1.0
                }
            }
        }
        return data
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        if metric == .macros {
            let proteinData = entries.compactMap { entry -> TimeSeriesDatapoint? in
                guard let protein = entry.proteinGrams else { return nil }
                return TimeSeriesDatapoint(id: "\(entry.id)-p", date: entry.date, value: protein)
            }
            let carbsData = entries.compactMap { entry -> TimeSeriesDatapoint? in
                guard let carbs = entry.carbGrams else { return nil }
                return TimeSeriesDatapoint(id: "\(entry.id)-c", date: entry.date, value: carbs)
            }
            let fatData = entries.compactMap { entry -> TimeSeriesDatapoint? in
                guard let fats = entry.fatGrams else { return nil }
                return TimeSeriesDatapoint(id: "\(entry.id)-f", date: entry.date, value: fats)
            }
            return [
                TimeSeriesData.TimeSeries(name: "Protein", data: proteinData),
                TimeSeriesData.TimeSeries(name: "Carbs", data: carbsData),
                TimeSeriesData.TimeSeries(name: "Fat", data: fatData)
            ]
        }
        let data = entries.map { TimeSeriesDatapoint(id: $0.id, date: $0.date, value: $0.value) }
        return [TimeSeriesData.TimeSeries(name: metric.title, data: data)]
    }

    var configuration: MetricConfiguration {
        if metric == .macros {
            return MetricConfiguration(
                title: metric.title,
                analyticsName: "NutritionMetricDetail_Macros",
                yAxisSuffix: "",
                seriesNames: ["Protein", "Carbs", "Fat"],
                showsAddButton: false,
                sectionHeader: "Daily Values",
                emptyStateMessage: "No macro data. Log meals to see your nutrition over time.",
                pageSize: 20,
                chartColor: nil,
                chartType: .stackedBar,
                isMacrosChart: true,
                macrosYAxisSuffix: " g"
            )
        }
        return MetricConfiguration(
            title: metric.title,
            analyticsName: "NutritionMetricDetail_\(metric.title.replacingOccurrences(of: " ", with: ""))",
            yAxisSuffix: metric.yAxisSuffix,
            seriesNames: [metric.title],
            showsAddButton: false,
            sectionHeader: "Daily Values",
            emptyStateMessage: "No \(metric.title.lowercased()) data. Log meals to see your nutrition over time.",
            pageSize: 20,
            chartColor: metric.chartColor,
            chartType: .bar
        )
    }

    init(interactor: NutritionAnalyticsInteractor, router: NutritionAnalyticsRouter, metric: NutritionMetric) {
        self.interactor = interactor
        self.router = router
        self.metric = metric
    }

    func onAppear() async {
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .year, value: -1, to: endDate) else { return }
        let startDayKey = calendar.startOfDay(for: startDate).dayKey
        let endDayKey = calendar.startOfDay(for: endDate).dayKey

        var newEntries: [NutritionMetricEntry] = []

        if metric == .macros {
            let totalsData = (try? interactor.getDailyTotals(startDayKey: startDayKey, endDayKey: endDayKey)) ?? []
            for item in totalsData {
                guard let date = Date(dayKey: item.dayKey) else { continue }
                let totals = item.totals
                let total = totals.proteinGrams + totals.carbGrams + totals.fatGrams
                guard total > 0 else { continue }
                newEntries.append(NutritionMetricEntry(
                    date: date,
                    value: totals.calories,
                    metric: metric,
                    proteinGrams: totals.proteinGrams,
                    carbGrams: totals.carbGrams,
                    fatGrams: totals.fatGrams
                ))
            }
        } else if metric.usesTotals {
            let totalsData = (try? interactor.getDailyTotals(startDayKey: startDayKey, endDayKey: endDayKey)) ?? []
            for item in totalsData {
                guard let date = Date(dayKey: item.dayKey),
                      let value = metric.extractValue(totals: item.totals, breakdown: nil),
                      value > 0 else { continue }
                newEntries.append(NutritionMetricEntry(date: date, value: value, metric: metric))
            }
        } else {
            let breakdownData = (try? interactor.getDailyNutritionBreakdown(startDayKey: startDayKey, endDayKey: endDayKey)) ?? []
            for item in breakdownData {
                guard let date = Date(dayKey: item.dayKey),
                      let value = metric.extractValue(totals: nil, breakdown: item.breakdown),
                      value > 0 else { continue }
                newEntries.append(NutritionMetricEntry(date: date, value: value, metric: metric))
            }
        }

        entries = newEntries.sorted { $0.date < $1.date }
    }

    func onAddPressed() {
        // No-op: nutrition is derived from meals
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDeleteEntry(_ entry: NutritionMetricEntry) async {
        // No-op: entries are derived from meals; deletion not supported at metric level
    }
}

extension CoreRouter {
    func showNutritionMetricDetailView(metric: NutritionMetric, delegate: NutritionMetricDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.nutritionMetricDetailView(router: router, metric: metric, delegate: delegate)
        }
    }
}

extension CoreBuilder {
    func nutritionMetricDetailView(router: Router, metric: NutritionMetric, delegate: NutritionMetricDetailDelegate) -> some View {
        MetricDetailView(
            presenter: NutritionMetricDetailPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                metric: metric
            )
        )
    }
}
