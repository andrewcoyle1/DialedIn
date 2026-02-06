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

#Preview("With Data") {
    List {
        Section {
            HistoryChart(series: TimeSeriesData.lastYear, yAxisSuffix: " kg")
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
                series: TimeSeriesData.lastYear,
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
