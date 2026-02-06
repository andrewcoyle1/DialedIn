//
//  HistoryChart.swift
//  ArchitectureProject
//
//  Created by Andrew Coyle on 05/02/2026.
//

import SwiftUI
import Charts

struct NewHistoryChart: View {
    enum ChartType {
        case line
        case bar
    }
    
    struct VisibleMetrics {
        var startDate: Date?
        var endDate: Date?
        var average: Double?
        var delta: Double?
        
        static let empty = VisibleMetrics(
            startDate: nil,
            endDate: nil,
            average: nil,
            delta: nil
        )
    }
    
    @State var scrollZoomState: ChartScrollZoomState = ChartScrollZoomState(initialVisibleDays: 7)
    @State private var visibleMetrics: VisibleMetrics = .empty
    
    var xStrideComponent: Calendar.Component {
        switch scrollZoomState.visibleDomainLength / 86400 {
        case 51...:
            return .month
        case 10...:
            return .weekOfYear
        default:
            return .day
        }
    }

    var series: [TimeSeriesData.TimeSeries]
    var yAxisSuffix: String = ""
    var chartType: ChartType = .line
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            
            Chart {
                ForEach(series) { singleSeries in
                    
                    if chartType == .line {
                        ForEach(singleSeries.data) { day in
                            LineMark(
                                x: .value("Date", day.date, unit: .day),
                                y: .value("Value", day.value)
                            )
                            .interpolationMethod(.catmullRom)
                            
                        }
                        .foregroundStyle(by: .value("Exercise", singleSeries.name))
                        
                        if let last = singleSeries.lastByDate {
                            PointMark(
                                x: .value("Date", last.date, unit: .day),
                                y: .value("Value", last.value)
                            )
                            .foregroundStyle(by: .value("Exercise", singleSeries.name))
                        }
                    } else {
                        ForEach(singleSeries.data) { day in
                            BarMark(
                                x: .value("Date", day.date, unit: .day),
                                yStart: .value("Value", 0),
                                yEnd: .value("Value", day.value)
                            )
                            .interpolationMethod(.catmullRom)
                            
                        }
                        .foregroundStyle(by: .value("Exercise", singleSeries.name))

                    }
                }
            }
            .scrollableAndMagnifiable(state: scrollZoomState)
            .chartXScale(domain: xAxisDomain)
            .autoYScale(
                series: series,
                scrollZoomState: scrollZoomState,
                metrics: $visibleMetrics
            )
            .chartXAxis {
                AxisMarks(values: .stride(by: xStrideComponent, count: 1)) { value in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: xAxisLabelFormat)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 2)
    }
    
    var xAxisLabelFormat: Date.FormatStyle {
        switch xStrideComponent {
        case .month:
            return .dateTime.month(.abbreviated)
        default:
            return .dateTime.month(.abbreviated).day(.defaultDigits)
        }
    }

    private var headerView: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text("Average")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text(formatValue(visibleMetrics.average))
                    Text(unitLabel)
                        .font(.caption)
                }
                Text(dateRangeText)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Difference")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text(formatValue(visibleMetrics.delta, showSign: true))
                    Text(unitLabel)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var unitLabel: String {
        yAxisSuffix.trimmingCharacters(in: .whitespaces)
    }
    
    private var dateRangeText: String {
        guard let start = visibleMetrics.startDate,
              let end = visibleMetrics.endDate else {
            return "--"
        }
        
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .dayOfYear) {
            let endFormatted = end.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year())
            return "\(endFormatted)"
        } else if Calendar.current.isDate(start, equalTo: end, toGranularity: .month) {
            let startFormatted = start.formatted(.dateTime.day(.defaultDigits))
            let endFormatted = end.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year())
            return "\(startFormatted) - \(endFormatted)"
        } else if Calendar.current.isDate(start, equalTo: end, toGranularity: .year) {
            let startFormatted = start.formatted(.dateTime.month(.abbreviated).day(.defaultDigits))
            let endFormatted = end.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year())
            return "\(startFormatted) - \(endFormatted)"
        } else if start > end {
            return "--"
        } else {
            let startFormatted = start.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year())
            let endFormatted = end.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year())
            return "\(startFormatted) - \(endFormatted)"
        }
    }
    
    private func formatValue(_ value: Double?, showSign: Bool = false) -> String {
        guard let value else { return "--" }
        let formatted = String(format: "%.1f", value)
        return showSign && value >= 0 ? "+\(formatted)" : formatted
    }
    
    private var xAxisDomain: ClosedRange<Date> {
        // Find the earliest and latest dates across all series
        let allDates = series.flatMap { $0.data.map { $0.date } }
        guard let earliest = allDates.min(),
              let latest = allDates.max() else {
            // Fallback: last year to now
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date.now) ?? Date.now
            return oneYearAgo...Date.now
        }
        
        // Extend 4 days into the future
        let fourDaysInSeconds: TimeInterval = 4 * 24 * 60 * 60
        let extendedLatest = latest.addingTimeInterval(fourDaysInSeconds)
        
        return earliest...extendedLatest
    }
}

private struct AutoYScaleModifier: ViewModifier {
    let series: [TimeSeriesData.TimeSeries]
    @Bindable var scrollZoomState: ChartScrollZoomState
    @Binding var metrics: NewHistoryChart.VisibleMetrics
    var debounce: Duration = .milliseconds(50)
    var minUpdateInterval: Duration = .milliseconds(75)

    @State private var yDomain: ClosedRange<Double> = 0...1
    @State private var cachedAllValues: [TimeSeriesDatapoint] = []
    @State private var updateTask: Task<Void, Never>?
    @State private var lastUpdateTime: Date?

    func body(content: Content) -> some View {
        content
            .chartYScale(domain: yDomain)
            .onAppear {
                rebuildCache()
                scheduleUpdate()
            }
            .onChange(of: seriesSignature) { _, _ in
                rebuildCache()
                scheduleUpdate()
            }
            .onChange(of: scrollZoomState.scrollPosition) { _, _ in
                scheduleUpdate()
            }
            .onChange(of: scrollZoomState.currentZoomDays) { _, _ in
                scheduleUpdate()
            }
            .onChange(of: scrollZoomState.totalZoomDays) { _, _ in
                scheduleUpdate()
            }
    }

    private var seriesSignature: Int {
        var hasher = Hasher()
        series.forEach { item in
            hasher.combine(item.id)
            hasher.combine(item.data.count)
            if let lastDate = item.lastByDate?.date {
                hasher.combine(lastDate)
            }
        }
        return hasher.finalize()
    }

    private func scheduleUpdate() {
        updateTask?.cancel()
        let now = Date()
        if shouldUpdateNow(now) {
            updateVisibleDomain()
            lastUpdateTime = now
        }
        updateTask = Task { @MainActor in
            let delay = remainingDelay(from: now)
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }
            updateVisibleDomain()
            lastUpdateTime = Date()
        }
    }

    private func shouldUpdateNow(_ now: Date) -> Bool {
        guard let lastUpdateTime else { return true }
        return now.timeIntervalSince(lastUpdateTime) >= minUpdateIntervalSeconds
    }

    private func remainingDelay(from now: Date) -> Duration {
        let throttleDelay: Duration
        if let lastUpdateTime {
            let elapsed = now.timeIntervalSince(lastUpdateTime)
            let remaining = max(0, minUpdateIntervalSeconds - elapsed)
            throttleDelay = .seconds(remaining)
        } else {
            throttleDelay = .zero
        }
        return max(throttleDelay, debounce)
    }

    private var minUpdateIntervalSeconds: Double {
        let components = minUpdateInterval.components
        return Double(components.seconds) + (Double(components.attoseconds) / 1_000_000_000_000_000_000)
    }

    private func rebuildCache() {
        cachedAllValues = series
            .flatMap { $0.data }
            .sorted { $0.date < $1.date }
    }

    private func updateVisibleDomain() {
        guard !cachedAllValues.isEmpty else {
            yDomain = 0...1
            metrics = .empty
            return
        }

        let start = scrollZoomState.scrollPosition
        let end = start.addingTimeInterval(scrollZoomState.visibleDomainLength)
        guard let range = DateSortedSearch.visibleRange(
            start: start,
            end: end,
            values: cachedAllValues
        ) else {
            // No datapoints in the visible region — emit nil metrics
            metrics = .empty
            return
        }

        let visibleValues = Array(cachedAllValues[range])
        
        var minValue = Double.greatestFiniteMagnitude
        var maxValue = -Double.greatestFiniteMagnitude
        for element in visibleValues {
            minValue = min(minValue, element.value)
            maxValue = max(maxValue, element.value)
        }
        setDomain(minValue: minValue, maxValue: maxValue)
        calculateMetrics(for: visibleValues)
    }
    
    private func calculateMetrics(for values: [TimeSeriesDatapoint]) {
        guard !values.isEmpty else {
            metrics = .empty
            return
        }
        
        let average = values.reduce(0.0) { $0 + $1.value } / Double(values.count)
        let startValue = values.first?.value
        let endValue = values.last?.value
        let delta: Double? = {
            guard let start = startValue, let end = endValue else { return nil }
            return end - start
        }()
        
        metrics = NewHistoryChart.VisibleMetrics(
            startDate: values.first?.date,
            endDate: values.last?.date,
            average: average,
            delta: delta
        )
    }

    private func setDomain(for values: [TimeSeriesDatapoint]) {
        let domain = ChartYDomainCalculator.paddedDomain(
            for: values.map(\.value),
            config: yDomainConfig
        )
        yDomain = domain
    }

    private func setDomain(minValue: Double, maxValue: Double) {
        let domain = ChartYDomainCalculator.paddedDomain(
            minValue: minValue,
            maxValue: maxValue,
            config: yDomainConfig
        )
        yDomain = domain
    }

    private var yDomainConfig: ChartYDomainCalculator.Configuration {
        .init(
            rangePaddingPercent: 0.1,
            minValuePaddingPercent: 0.05,
            minimumPadding: 0.5
        )
    }
}

private extension View {
    func autoYScale(
        series: [TimeSeriesData.TimeSeries],
        scrollZoomState: ChartScrollZoomState,
        metrics: Binding<NewHistoryChart.VisibleMetrics>,
        debounce: Duration = .milliseconds(50),
        minUpdateInterval: Duration = .milliseconds(250)
    ) -> some View {
        modifier(
            AutoYScaleModifier(
                series: series,
                scrollZoomState: scrollZoomState,
                metrics: metrics,
                debounce: debounce,
                minUpdateInterval: minUpdateInterval
            )
        )
    }
}

#Preview("Line Chart") {
    NewHistoryChart(series: TimeSeriesData.lastYear, yAxisSuffix: " kg")
}

#Preview("Bar Chart") {
    NewHistoryChart(series: TimeSeriesData.lastYear, yAxisSuffix: " kg", chartType: NewHistoryChart.ChartType.bar)
}
