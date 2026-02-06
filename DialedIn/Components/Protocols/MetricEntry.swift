import Foundation

protocol MetricEntry: Identifiable {
    var id: String { get }
    var date: Date { get }
    var displayLabel: String { get }
    var displayValue: String { get }
    var systemImageName: String { get }
    func timeSeriesData() -> [(seriesName: String, date: Date, value: Double)]
}
