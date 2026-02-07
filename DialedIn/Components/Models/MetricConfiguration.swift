import Foundation
import SwiftUI

struct MetricConfiguration {
    let title: String
    let analyticsName: String
    let yAxisSuffix: String
    let seriesNames: [String]
    let showsAddButton: Bool
    let sectionHeader: String
    let emptyStateMessage: String
    /// If set, the metric entries list paginates using this page size.
    let pageSize: Int?
    /// Optional color for the chart. When provided, all series will use this color.
    let chartColor: Color?
    /// Chart display style. Defaults to line when nil.
    let chartType: NewHistoryChart.ChartType?
    /// When true, chart shows stacked protein/carbs/fat bars with three-averages header.
    let isMacrosChart: Bool
    /// Y-axis suffix for stacked macros chart (e.g. " g").
    let macrosYAxisSuffix: String?

    init(
        title: String,
        analyticsName: String,
        yAxisSuffix: String,
        seriesNames: [String],
        showsAddButton: Bool,
        sectionHeader: String,
        emptyStateMessage: String,
        pageSize: Int? = nil,
        chartColor: Color? = nil,
        chartType: NewHistoryChart.ChartType? = nil,
        isMacrosChart: Bool = false,
        macrosYAxisSuffix: String? = nil
    ) {
        self.title = title
        self.analyticsName = analyticsName
        self.yAxisSuffix = yAxisSuffix
        self.seriesNames = seriesNames
        self.showsAddButton = showsAddButton
        self.sectionHeader = sectionHeader
        self.emptyStateMessage = emptyStateMessage
        self.pageSize = pageSize
        self.chartColor = chartColor
        self.chartType = chartType
        self.isMacrosChart = isMacrosChart
        self.macrosYAxisSuffix = macrosYAxisSuffix
    }
}
