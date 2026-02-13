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
        let strictRange = DateSortedSearch.visibleRange(start: start, end: end, values: cachedAllValues)
        let (extendedLower, extendedUpper) = extendedVisibleIndices(start: start, end: end)
        guard extendedLower < extendedUpper else {
            applyFallbackDomainAndMetrics(start: start, end: end)
            return
        }
        let (minValue, maxValue) = minMaxValues(in: extendedLower..<extendedUpper)
        setDomain(minValue: minValue, maxValue: maxValue)
        if let range = strictRange {
            calculateMetrics(for: Array(cachedAllValues[range]), xStart: start, xEnd: end)
        } else {
            metrics = emptyMetrics(startDate: start, endDate: end)
        }
    }

    private func extendedVisibleIndices(start: Date, end: Date) -> (Int, Int) {
        let lowerIndex = DateSortedSearch.lowerBound(for: start, values: cachedAllValues)
        let upperIndex = DateSortedSearch.upperBound(for: end, values: cachedAllValues)
        let extendedLower = max(lowerIndex - 1, 0)
        let extendedUpper = min(upperIndex + 1, cachedAllValues.count)
        return (extendedLower, extendedUpper)
    }

    private func applyFallbackDomainAndMetrics(start: Date, end: Date) {
        if let first = cachedAllValues.first, let last = cachedAllValues.last {
            let allMin = cachedAllValues.map(\.value).min() ?? 0
            let allMax = cachedAllValues.map(\.value).max() ?? 1
            setDomain(minValue: allMin, maxValue: allMax)
            calculateMetrics(for: cachedAllValues, xStart: first.date, xEnd: last.date)
        } else {
            metrics = .empty
        }
    }

    private func minMaxValues(in range: Range<Int>) -> (min: Double, max: Double) {
        var minValue = Double.greatestFiniteMagnitude
        var maxValue = -Double.greatestFiniteMagnitude
        for element in cachedAllValues[range] {
            minValue = min(minValue, element.value)
            maxValue = max(maxValue, element.value)
        }
        return (minValue, maxValue)
    }

    private func updateVisibleDomainStacked() {
        let start = scrollZoomState.scrollPosition
        let end = start.addingTimeInterval(scrollZoomState.visibleDomainLength)
        let byDate = buildMacroTotalsByDate(
            proteinSeries: series[0],
            carbsSeries: series[1],
            fatSeries: series[2],
            start: start,
            end: end
        )
        let dates = byDate.keys.sorted()
        guard !dates.isEmpty else {
            yDomain = 0...1
            metrics = emptyMetrics(startDate: start, endDate: end)
            return
        }
        let sums = aggregateMacroSums(dates: dates, byDate: byDate)
        setDomain(minValue: 0, maxValue: max(sums.maxSum, 1))
        metrics = stackedBarMetrics(start: start, end: end, count: dates.count, sums: sums)
    }

    private struct MacroTotals {
        var protein: Double = 0
        var carbs: Double = 0
        var fat: Double = 0
    }

    private struct MacroSums {
        var maxSum: Double
        var sumP: Double
        var sumC: Double
        var sumF: Double
    }

    private func buildMacroTotalsByDate(
        proteinSeries: TimeSeriesData.TimeSeries,
        carbsSeries: TimeSeriesData.TimeSeries,
        fatSeries: TimeSeriesData.TimeSeries,
        start: Date,
        end: Date
    ) -> [Date: MacroTotals] {
        var byDate: [Date: MacroTotals] = [:]
        for protein in proteinSeries.sortedByDate where protein.date >= start && protein.date <= end {
            var totals = byDate[protein.date, default: MacroTotals()]
            totals.protein = protein.value
            byDate[protein.date] = totals
        }
        for carb in carbsSeries.sortedByDate {
            var totals = byDate[carb.date, default: MacroTotals()]
            totals.carbs = carb.value
            byDate[carb.date] = totals
        }
        for fats in fatSeries.sortedByDate {
            var totals = byDate[fats.date, default: MacroTotals()]
            totals.fat = fats.value
            byDate[fats.date] = totals
        }
        return byDate
    }

    private func aggregateMacroSums(dates: [Date], byDate: [Date: MacroTotals]) -> MacroSums {
        var maxSum: Double = 0
        var sumP: Double = 0, sumC: Double = 0, sumF: Double = 0
        for date in dates {
            let total = byDate[date] ?? MacroTotals()
            maxSum = max(maxSum, total.protein + total.carbs + total.fat)
            sumP += total.protein
            sumC += total.carbs
            sumF += total.fat
        }
        return MacroSums(maxSum: maxSum, sumP: sumP, sumC: sumC, sumF: sumF)
    }

    private func emptyMetrics(startDate: Date, endDate: Date) -> NewHistoryChart.VisibleMetrics {
        NewHistoryChart.VisibleMetrics(
            startDate: startDate,
            endDate: endDate,
            average: nil,
            delta: nil,
            averageProtein: nil,
            averageCarbs: nil,
            averageFat: nil
        )
    }

    private func stackedBarMetrics(start: Date, end: Date, count: Int, sums: MacroSums) -> NewHistoryChart.VisibleMetrics {
        let number = Double(count)
        return NewHistoryChart.VisibleMetrics(
            startDate: start,
            endDate: end,
            average: nil,
            delta: nil,
            averageProtein: number > 0 ? sums.sumP / number : nil,
            averageCarbs: number > 0 ? sums.sumC / number : nil,
            averageFat: number > 0 ? sums.sumF / number : nil
        )
    }

    private func calculateMetrics(for values: [TimeSeriesDatapoint], xStart: Date, xEnd: Date) {
        guard !values.isEmpty else {
            metrics = emptyMetrics(startDate: xStart, endDate: xEnd)
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
