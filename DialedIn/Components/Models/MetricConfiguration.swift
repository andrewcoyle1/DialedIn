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
    
    init(
        title: String,
        analyticsName: String,
        yAxisSuffix: String,
        seriesNames: [String],
        showsAddButton: Bool,
        sectionHeader: String,
        emptyStateMessage: String,
        pageSize: Int? = nil,
        chartColor: Color? = nil
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
    }
}
