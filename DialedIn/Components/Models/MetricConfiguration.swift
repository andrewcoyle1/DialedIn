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
    /// Optional color for the chart. When provided, all series will use this color.
    let chartColor: Color?
    /// Chart display style. Defaults to line when nil.
    let chartType: NewHistoryChart.ChartType?
    /// When true, chart shows stacked protein/carbs/fat bars with three-averages header.
    let isMacrosChart: Bool
    /// Y-axis suffix for stacked macros chart (e.g. " g").
    let macrosYAxisSuffix: String?
    /// What the toolbar action does, for screens whose data is not entered here. Several of these
    /// screens showed no action at all and documented, in a comment, that the user should go and do
    /// the thing somewhere else — so the title names that destination and the icon matches it
    /// ("plus" is wrong for "Start Workout" or "Sync from Health").
    let addActionTitle: String
    let addActionSystemImage: String

    /// `yAxisSuffix` carries a leading space because a chart axis wants one (" kg"). An entry row
    /// builds its own spacing, so it needs the bare unit — concatenating the suffix there produced
    /// "72.4  kg" with a double space on every row of every one of these screens.
    ///
    /// Empty for the macros chart: its rows read "120g P · 300g C · 70g F", which already names
    /// every unit it contains. `macrosYAxisSuffix` is for that chart's axis, not its rows.
    var unitText: String {
        guard !isMacrosChart else { return "" }
        return yAxisSuffix.trimmingCharacters(in: .whitespaces)
    }

    init(
        title: String,
        analyticsName: String,
        yAxisSuffix: String,
        seriesNames: [String],
        showsAddButton: Bool,
        sectionHeader: String,
        emptyStateMessage: String,
        chartColor: Color? = nil,
        chartType: NewHistoryChart.ChartType? = nil,
        isMacrosChart: Bool = false,
        macrosYAxisSuffix: String? = nil,
        addActionTitle: String = "Add Entry",
        addActionSystemImage: String = "plus"
    ) {
        self.title = title
        self.analyticsName = analyticsName
        self.yAxisSuffix = yAxisSuffix
        self.seriesNames = seriesNames
        self.showsAddButton = showsAddButton
        self.sectionHeader = sectionHeader
        self.emptyStateMessage = emptyStateMessage
        self.chartColor = chartColor
        self.chartType = chartType
        self.isMacrosChart = isMacrosChart
        self.macrosYAxisSuffix = macrosYAxisSuffix
        self.addActionTitle = addActionTitle
        self.addActionSystemImage = addActionSystemImage
    }
}
