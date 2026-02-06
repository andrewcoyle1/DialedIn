import Foundation

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
}
