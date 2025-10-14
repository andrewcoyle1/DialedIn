//
//  HistoryChart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/10/2025.
//

import SwiftUI
import Charts

func date(year: Int, month: Int, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

struct TimeSeriesDatapoint: Identifiable {
    var id = UUID().uuidString
    var date: Date
    var value: Double
}

struct TimeSeriesData {
    struct TimeSeries: Identifiable {
        
        /// Series name
        let name: String
        
        /// Dataset
        let data: [(date: Date, value: Double)]
        
        /// The identifier for the series
        var id: String {
            name
        }
    }
    
    /// Mock data for demo-ing charts
    static let last30Days: [TimeSeries] = [
        .init(name: "Bench Press", data: [
            (date: date(year: 2022, month: 5, day: 2), value: 54),
            (date: date(year: 2022, month: 5, day: 3), value: 42),
            (date: date(year: 2022, month: 5, day: 4), value: 88),
            (date: date(year: 2022, month: 5, day: 5), value: 49),
            (date: date(year: 2022, month: 5, day: 6), value: 42),
            (date: date(year: 2022, month: 5, day: 7), value: 125),
            (date: date(year: 2022, month: 5, day: 8), value: 67)
        ]),
        .init(name: "Barbell Squat", data: [
            (date: date(year: 2022, month: 5, day: 2), value: 81),
            (date: date(year: 2022, month: 5, day: 3), value: 90),
            (date: date(year: 2022, month: 5, day: 4), value: 52),
            (date: date(year: 2022, month: 5, day: 5), value: 72),
            (date: date(year: 2022, month: 5, day: 6), value: 84),
            (date: date(year: 2022, month: 5, day: 7), value: 84),
            (date: date(year: 2022, month: 5, day: 8), value: 137)
        ])
    ]
    
}

// MARK: - Helpers
extension TimeSeriesData.TimeSeries {
    var sortedByDate: [(date: Date, value: Double)] {
        data.sorted { $0.date < $1.date }
    }
    var lastByDate: (date: Date, value: Double)? {
        data.max { $0.date < $1.date }
    }
}

struct HistoryChart: View {
    
    var series: [TimeSeriesData.TimeSeries]
    
    let symbolSize: CGFloat = 100
    let lineWidth: CGFloat = 3
    
    let showsLegend: Bool = true
    
    var colorMapping: [String: Color]?
    var symbolMapping: [String: AnyChartSymbolShape]? 
    
    /// Optional suffix appended to Y-axis tick labels (e.g., " kg")
    var yAxisSuffix: String?
    
    var body: some View {
        Group {
            if series.isEmpty {
                ContentUnavailableView("No Data", systemImage: "info.circle")
            } else {
                Chart {
                    // For each series, render marks using a smaller, dedicated ChartContent
                    ForEach(series) { series in
                        SeriesMarks(series: series, lineWidth: lineWidth, symbolSize: symbolSize)
                    }
                }
                .applyChartForegroundStyleScale(colorMapping)
                .applyChartSymbolScale(symbolMapping)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisTick()
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.day(.defaultDigits).month(.abbreviated))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisTick()
                        AxisGridLine()
                        AxisValueLabel {
                            if let raw: Double = value.as(Double.self) {
                                Text(formatYAxisValue(raw))
                            }
                        }
                    }
                }
                .chartLegend(showsLegend ? .visible : .hidden)
                .padding(.leading, 6)
                .padding(.top, 6)
            }
        }
        .frame(minHeight: 200)
    }
    
    // MARK: - Private helpers
    private func formatYAxisValue(_ value: Double) -> String {
        let number = value.formatted()
        if let suffix = yAxisSuffix, !suffix.isEmpty {
            return number + suffix
        }
        return number
    }
    
}

// MARK: - Per-series chart content
private struct SeriesMarks: ChartContent {
    let series: TimeSeriesData.TimeSeries
    let lineWidth: CGFloat
    let symbolSize: CGFloat
    
    var body: some ChartContent {
        // Line marks for the series
        ForEach(series.sortedByDate, id: \.date) { datapoint in
            LineMark(
                x: .value("Date", datapoint.date, unit: .day),
                y: .value("Value", datapoint.value)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: lineWidth))
        }
        .foregroundStyle(by: .value("Name", series.name))
        
        // Highlight the last point in the series
        if let last = series.lastByDate {
            PointMark(
                x: .value("Date", last.date, unit: .day),
                y: .value("Value", last.value)
            )
            .symbol(by: .value("Name", series.name))
            .symbolSize(symbolSize)
        }
    }
}

// MARK: - View Extensions for Conditional Chart Styling
extension View {
    @ViewBuilder
    func applyChartForegroundStyleScale(_ mapping: [String: Color]?) -> some View {
        if let mapping = mapping {
            let sorted = mapping.sorted { $0.key < $1.key }
            let domain = sorted.map { $0.key }
            let range = sorted.map { $0.value }
            self.chartForegroundStyleScale(domain: domain, range: range)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyChartSymbolScale(_ mapping: [String: AnyChartSymbolShape]?) -> some View {
        if let mapping = mapping {
            let sorted = mapping.sorted { $0.key < $1.key }
            let domain = sorted.map { $0.key }
            let range = sorted.map { $0.value }
            self.chartSymbolScale(domain: domain, range: range)
        } else {
            self
        }
    }
}

#Preview("With Data") {
    List {
        Section {
            HistoryChart(series: TimeSeriesData.last30Days, yAxisSuffix: " kg")
        } header: {
            Text("History Chart")
        }
    }
}

#Preview("Without Data") {
    List {
        Section {
            HistoryChart(series: [])
        } header: {
            Text("History Chart")
        }
    }
}

#Preview("With Custom Colors") {
    List {
        Section {
            HistoryChart(
                series: TimeSeriesData.last30Days,
                colorMapping: [
                    "Bench Press": .purple,
                    "Barbell Squat": .green
                ],
                symbolMapping: [
                    "Bench Press": AnyChartSymbolShape(Circle()),
                    "Barbell Squat": AnyChartSymbolShape(Circle())
                ]
            )
        } header: {
            Text("History Chart")
        }
    }
}
