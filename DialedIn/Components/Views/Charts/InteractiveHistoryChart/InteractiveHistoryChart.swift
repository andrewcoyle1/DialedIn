//
//  InteractiveHistoryChart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/02/2026.
//

import SwiftUI
import Charts

struct InteractiveHistoryChart: View {

    @State private var model: InteractiveHistoryChartModel

    var series: [TimeSeriesData.TimeSeries]
    var showsLegend: Bool = true
    var colorMapping: [String: Color]?
    var symbolMapping: [String: AnyChartSymbolShape]?
    var yAxisSuffix: String?
    var onVisibleMetricsChange: ((InteractiveHistoryChartModel.VisibleRangeMetrics) -> Void)?

    private let symbolSize: CGFloat = 100
    private let lineWidth: CGFloat = 3

    init(
        series: [TimeSeriesData.TimeSeries],
        showsLegend: Bool = true,
        colorMapping: [String: Color]? = nil,
        symbolMapping: [String: AnyChartSymbolShape]? = nil,
        yAxisSuffix: String? = nil,
        initialVisibleDays: Double = 7,
        onVisibleMetricsChange: ((InteractiveHistoryChartModel.VisibleRangeMetrics) -> Void)? = nil
    ) {
        self.series = series
        self.showsLegend = showsLegend
        self.colorMapping = colorMapping
        self.symbolMapping = symbolMapping
        self.yAxisSuffix = yAxisSuffix
        self.onVisibleMetricsChange = onVisibleMetricsChange
        _model = State(
            initialValue: InteractiveHistoryChartModel(
                series: series,
                initialVisibleDays: initialVisibleDays
            )
        )
    }

    var body: some View {
        Group {
            if series.isEmpty {
                ContentUnavailableView("No Data", systemImage: "info.circle")
            } else {
                chartView
            }
        }
        .frame(minHeight: 200)
        .onAppear {
            model.onVisibleMetricsChange = onVisibleMetricsChange
            model.initializeIfNeeded()
        }
        .onChange(of: seriesSignature) { _, _ in
            model.updateSeries(series)
        }
    }

    private var chartView: some View {
        @Bindable var model = model
        return Chart {
            ForEach(series) { series in
                InteractiveSeriesMarks(
                    seriesName: series.name,
                    data: model.visibleSeriesData(for: series),
                    lineWidth: lineWidth,
                    symbolSize: symbolSize
                )
            }
        }
        .scrollableAndMagnifiable(state: model.scrollZoomState)
        .applyChartForegroundStyleScale(colorMapping)
        .applyChartSymbolScale(symbolMapping)
        .applyChartXScale(model.xDomain)
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisTick()
                AxisGridLine()
                AxisValueLabel {
                    if let raw: Double = value.as(Double.self) {
                        Text(model.formatYAxisValue(raw, suffix: yAxisSuffix))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: model.xStrideComponent, count: 1)) { value in
                AxisTick()
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: model.xAxisLabelFormat)
                    }
                }
            }
        }
        .chartYScale(domain: model.yDomain)
        .chartLegend(showsLegend ? .visible : .hidden)
        .padding(.leading, 6)
        .padding(.top, 6)
    }

    private var seriesSignature: [Int] {
        series.map { $0.data.count }
    }
}

private struct InteractiveSeriesMarks: ChartContent {
    let seriesName: String
    let data: [TimeSeriesDatapoint]
    let lineWidth: CGFloat
    let symbolSize: CGFloat

    var body: some ChartContent {
        ForEach(data) { datapoint in
            LineMark(
                x: .value("Date", datapoint.date, unit: .day),
                y: .value("Value", datapoint.value)
            )
            .interpolationMethod(.linear)
            .lineStyle(StrokeStyle(lineWidth: lineWidth))
        }
        .foregroundStyle(by: .value("Name", seriesName))

        if let last = data.last {
            PointMark(
                x: .value("Date", last.date, unit: .day),
                y: .value("Value", last.value)
            )
            .symbol(by: .value("Name", seriesName))
            .symbolSize(symbolSize)
        }
    }
}

#Preview("Interactive History Chart") {
    List {
        Section {
            InteractiveHistoryChart(series: TimeSeriesData.lastYear, yAxisSuffix: " kg")
        } header: {
            Text("Interactive History Chart")
        }
    }
}
