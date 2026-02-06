//
//  AutoYScaleModifier.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI
import Charts

struct AutoYScaleModifier: ViewModifier {
    let series: [TimeSeriesData.TimeSeries]
    @Bindable var scrollZoomState: ChartScrollZoomState
    @Binding var metrics: NewHistoryChart.VisibleMetrics
    var debounce: Duration = .milliseconds(50)
    var minUpdateInterval: Duration = .milliseconds(75)

    @State private var yDomain: ClosedRange<Double> = 0...1
    @State private var yTicks: [Double] = [0, 1]
    @State private var cachedAllValues: [TimeSeriesDatapoint] = []
    @State private var updateTask: Task<Void, Never>?
    @State private var lastUpdateTime: Date?

    func body(content: Content) -> some View {
        content
            .chartYScale(domain: yDomain)
            .chartYAxis {
                AxisMarks(values: yTicks)
            }
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
        
        // Strict range: only points whose dates fall within the visible window (for metrics)
        let strictRange = DateSortedSearch.visibleRange(
            start: start,
            end: end,
            values: cachedAllValues
        )
        
        // Extended range: include one point before and after the visible window
        // so the interpolated line segments entering/leaving the view are covered
        let lowerIndex = DateSortedSearch.lowerBound(for: start, values: cachedAllValues)
        let upperIndex = DateSortedSearch.upperBound(for: end, values: cachedAllValues)
        let extendedLower = max(lowerIndex - 1, 0)
        let extendedUpper = min(upperIndex + 1, cachedAllValues.count)
        
        guard extendedLower < extendedUpper else {
            metrics = .empty
            return
        }
        
        // Use the extended range for the y-domain so the line never exceeds the axis
        var minValue = Double.greatestFiniteMagnitude
        var maxValue = -Double.greatestFiniteMagnitude
        for element in cachedAllValues[extendedLower..<extendedUpper] {
            minValue = min(minValue, element.value)
            maxValue = max(maxValue, element.value)
        }
        setDomain(minValue: minValue, maxValue: maxValue)
        
        // Use the strict range for header metrics, with x-axis bounds as the dates
        if let range = strictRange {
            calculateMetrics(for: Array(cachedAllValues[range]), xStart: start, xEnd: end)
        } else {
            metrics = NewHistoryChart.VisibleMetrics(
                startDate: start,
                endDate: end,
                average: nil,
                delta: nil
            )
        }
    }
    
    private func calculateMetrics(for values: [TimeSeriesDatapoint], xStart: Date, xEnd: Date) {
        guard !values.isEmpty else {
            metrics = NewHistoryChart.VisibleMetrics(
                startDate: xStart,
                endDate: xEnd,
                average: nil,
                delta: nil
            )
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
            startDate: xStart,
            endDate: xEnd,
            average: average,
            delta: delta
        )
    }

    private func setDomain(for values: [TimeSeriesDatapoint]) {
        guard let minVal = values.map(\.value).min(),
              let maxVal = values.map(\.value).max() else {
            yDomain = 0...1
            yTicks = [0, 1]
            return
        }
        setDomain(minValue: minVal, maxValue: maxVal)
    }

    private func setDomain(minValue: Double, maxValue: Double) {
        let scale = ChartYDomainCalculator.niceScale(
            minValue: minValue,
            maxValue: maxValue,
            maxTicks: 6
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            yDomain = scale.domain
            yTicks = scale.tickValues
        }
    }
}

extension View {
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
