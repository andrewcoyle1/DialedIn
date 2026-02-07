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
    /// When true, lower bound is always 0 and only the upper bound is auto-scaled (for BarMark charts).
    var yDomainIncludesZero: Bool = false
    /// When true, y-domain max is sum of series per date; metrics include averageProtein, averageCarbs, averageFat.
    var isStackedBar: Bool = false
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
                // Update immediately on first appearance, then schedule debounced updates
                updateVisibleDomain()
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
            .flatMap { $0.sortedByDate }
            .sorted { $0.date < $1.date }
    }

    private func updateVisibleDomain() {
        if isStackedBar, series.count >= 3 {
            updateVisibleDomainStacked()
            return
        }
        guard !cachedAllValues.isEmpty else {
            yDomain = 0...1
            metrics = .empty
            return
        }

        let start = scrollZoomState.scrollPosition
        let end = start.addingTimeInterval(scrollZoomState.visibleDomainLength)
        
        let strictRange = DateSortedSearch.visibleRange(
            start: start,
            end: end,
            values: cachedAllValues
        )
        let lowerIndex = DateSortedSearch.lowerBound(for: start, values: cachedAllValues)
        let upperIndex = DateSortedSearch.upperBound(for: end, values: cachedAllValues)
        let extendedLower = max(lowerIndex - 1, 0)
        let extendedUpper = min(upperIndex + 1, cachedAllValues.count)
        
        guard extendedLower < extendedUpper else {
            if let first = cachedAllValues.first, let last = cachedAllValues.last {
                let allMin = cachedAllValues.map(\.value).min() ?? 0
                let allMax = cachedAllValues.map(\.value).max() ?? 1
                setDomain(minValue: allMin, maxValue: allMax)
                calculateMetrics(for: cachedAllValues, xStart: first.date, xEnd: last.date)
            } else {
                metrics = .empty
            }
            return
        }
        
        var minValue = Double.greatestFiniteMagnitude
        var maxValue = -Double.greatestFiniteMagnitude
        for element in cachedAllValues[extendedLower..<extendedUpper] {
            minValue = min(minValue, element.value)
            maxValue = max(maxValue, element.value)
        }
        setDomain(minValue: minValue, maxValue: maxValue)
        
        if let range = strictRange {
            calculateMetrics(for: Array(cachedAllValues[range]), xStart: start, xEnd: end)
        } else {
            metrics = NewHistoryChart.VisibleMetrics(
                startDate: start,
                endDate: end,
                average: nil,
                delta: nil,
                averageProtein: nil,
                averageCarbs: nil,
                averageFat: nil
            )
        }
    }

    private func updateVisibleDomainStacked() {
        let start = scrollZoomState.scrollPosition
        let end = start.addingTimeInterval(scrollZoomState.visibleDomainLength)
        let proteinSeries = series[0]
        let carbsSeries = series[1]
        let fatSeries = series[2]
        var byDate: [Date: (Double, Double, Double)] = [:]
        for protein in proteinSeries.sortedByDate where protein.date >= start && protein.date <= end {
            byDate[protein.date, default: (0, 0, 0)].0 = protein.value
        }
        for carb in carbsSeries.sortedByDate where carb.date >= start && carb.date <= end {
            byDate[carb.date, default: (0, 0, 0)].1 = carb.value
        }
        for fat in fatSeries.sortedByDate where fat.date >= start && fat.date <= end {
            byDate[fat.date, default: (0, 0, 0)].2 = fat.value
        }
        let dates = byDate.keys.sorted()
        guard !dates.isEmpty else {
            yDomain = 0...1
            metrics = NewHistoryChart.VisibleMetrics(
                startDate: start,
                endDate: end,
                average: nil,
                delta: nil,
                averageProtein: nil,
                averageCarbs: nil,
                averageFat: nil
            )
            return
        }
        var maxSum: Double = 0
        var sumP: Double = 0, sumC: Double = 0, sumF: Double = 0
        for date in dates {
            let total = byDate[date] ?? (0, 0, 0)
            maxSum = max(maxSum, total.0 + total.1 + total.2)
            sumP += total.0
            sumC += total.1
            sumF += total.2
        }
        let number = Double(dates.count)
        setDomain(minValue: 0, maxValue: max(maxSum, 1))
        metrics = NewHistoryChart.VisibleMetrics(
            startDate: start,
            endDate: end,
            average: nil,
            delta: nil,
            averageProtein: number > 0 ? sumP / number : nil,
            averageCarbs: number > 0 ? sumC / number : nil,
            averageFat: number > 0 ? sumF / number : nil
        )
    }
    
    private func calculateMetrics(for values: [TimeSeriesDatapoint], xStart: Date, xEnd: Date) {
        guard !values.isEmpty else {
            metrics = NewHistoryChart.VisibleMetrics(
                startDate: xStart,
                endDate: xEnd,
                average: nil,
                delta: nil,
                averageProtein: nil,
                averageCarbs: nil,
                averageFat: nil
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
            delta: delta,
            averageProtein: nil,
            averageCarbs: nil,
            averageFat: nil
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
        let scale: ChartYDomainCalculator.NiceScale
        if yDomainIncludesZero {
            // Lower bound is always 0; only upper bound is auto-scaled
            scale = ChartYDomainCalculator.niceScale(
                minValue: 0,
                maxValue: max(maxValue, 1),
                maxTicks: 6
            )
            let domain = 0...scale.domain.upperBound
            let ticks = scale.tickValues.filter { $0 >= 0 }
            withAnimation(.easeInOut(duration: 0.25)) {
                yDomain = domain
                yTicks = ticks.isEmpty ? [0, domain.upperBound] : ticks
            }
        } else {
            scale = ChartYDomainCalculator.niceScale(
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
}

extension View {
    func autoYScale(
        series: [TimeSeriesData.TimeSeries],
        scrollZoomState: ChartScrollZoomState,
        metrics: Binding<NewHistoryChart.VisibleMetrics>,
        yDomainIncludesZero: Bool = false,
        isStackedBar: Bool = false,
        debounce: Duration = .milliseconds(50),
        minUpdateInterval: Duration = .milliseconds(250)
    ) -> some View {
        modifier(
            AutoYScaleModifier(
                series: series,
                scrollZoomState: scrollZoomState,
                metrics: metrics,
                yDomainIncludesZero: yDomainIncludesZero,
                isStackedBar: isStackedBar,
                debounce: debounce,
                minUpdateInterval: minUpdateInterval
            )
        )
    }
}
