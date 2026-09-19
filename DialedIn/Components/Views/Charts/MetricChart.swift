//
//  MetricChart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 19/09/2026.
//

import SwiftUI

/// The chart at the top of `MetricDetailView`, drawn with QuickCharts: a D/W/M/6M/Y picker, a
/// summary header, paged scrolling and press-and-hold selection.
struct MetricChart: View {
    let series: [TimeSeries]
    let configuration: MetricConfiguration
    /// Overrides `configuration.chartColor`, as `MetricDetailView`'s theme colour does.
    var color: Color?

    var body: some View {
        let chartConfiguration = configuration.quickChartsConfiguration(color: color)

        switch configuration.chartType ?? .line {
        case .line:
            LineChart(data: series, configuration: chartConfiguration)
        case .bar:
            BarChart(data: series, configuration: chartConfiguration)
        case .stackedBar:
            StackedBarChart(data: series, configuration: chartConfiguration)
        }
    }
}

@MainActor
extension MetricConfiguration {
    /// Bars are daily totals — steps, sets, calories — so a week or month bucket adds them up and the
    /// header shows the daily average, as Health does for steps. Lines are readings such as weight or
    /// a one-rep max, so buckets average them.
    fileprivate func quickChartsConfiguration(color: Color?) -> ChartConfiguration {
        let isTotal = chartType == .bar || chartType == .stackedBar
        let unit = isMacrosChart ? (macrosYAxisSuffix ?? " g") : yAxisSuffix

        return ChartConfiguration(
            aggregation: isTotal ? .sum : .average,
            summary: isTotal ? .dailyAverage : .combined,
            unit: unit.trimmingCharacters(in: .whitespaces),
            valueFormat: .number.precision(.fractionLength(isTotal ? 0 : 1)),
            // Every metric here has at most a reading or total a day, so D would show one point.
            availableScales: [.week, .month, .sixMonths, .year],
            seriesColors: seriesColors(color: color ?? chartColor),
            height: 220,
            accessibilityTitle: title
        )
    }

    /// A single colour paints every series, as `NewHistoryChart` did. The macros chart keeps the
    /// protein, carbs and fat colours used everywhere else in the app.
    private func seriesColors(color: Color?) -> [Color] {
        if isMacrosChart {
            return [MacroProgressChart.proteinColor, MacroProgressChart.carbsColor, MacroProgressChart.fatColor]
        }
        if let color {
            return [color]
        }
        return ChartConfiguration().seriesColors
    }
}
