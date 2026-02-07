//
//  HistoryChart.swift
//  ArchitectureProject
//
//  Created by Andrew Coyle on 05/02/2026.
//

import SwiftUI
import Charts

struct NewHistoryChart: View {
    
    @State var scrollZoomState = ChartScrollZoomState(
        initialVisibleDays: 7,
        config: .init(maxZoomDays: 3650)
    )
    @State private var visibleMetrics: VisibleMetrics = .empty
    @State private var selectedTimeRange: TimeRange = .oneWeek
    @State private var hasInitialized = false
    
    var series: [TimeSeriesData.TimeSeries]
    var yAxisSuffix: String = ""
    var chartType: ChartType = .line
    var chartColor: Color?
    
    private struct StackedBarDay {
        let date: Date
        let protein: Double
        let carbs: Double
        let fat: Double
    }

    private var stackedBarDayData: [StackedBarDay] {
        guard series.count >= 3 else { return [] }
        let proteinSeries = series[0]
        let carbsSeries = series[1]
        let fatSeries = series[2]
        var byDate: [Date: (Double, Double, Double)] = [:]
        for protein in proteinSeries.sortedByDate {
            byDate[protein.date, default: (0, 0, 0)].0 = protein.value
        }
        for carb in carbsSeries.sortedByDate {
            byDate[carb.date, default: (0, 0, 0)].1 = carb.value
        }
        for fats in fatSeries.sortedByDate {
            byDate[fats.date, default: (0, 0, 0)].2 = fats.value
        }
        return byDate.keys.sorted().map { date in
            let total = byDate[date] ?? (0, 0, 0)
            return StackedBarDay(date: date, protein: total.0, carbs: total.1, fat: total.2)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            
            Chart {
                if chartType == .stackedBar, series.count >= 3 {
                    ForEach(stackedBarDayData, id: \.date) { day in
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Protein", day.protein)
                        )
                        .foregroundStyle(MacroProgressChart.proteinColor)
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Carbs", day.carbs)
                        )
                        .foregroundStyle(MacroProgressChart.carbsColor)
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Fat", day.fat)
                        )
                        .foregroundStyle(MacroProgressChart.fatColor)
                    }
                } else {
                    ForEach(series) { singleSeries in
                        if chartType == .line {
                            let lineMarks = ForEach(singleSeries.sortedByDate) { day in
                                LineMark(
                                    x: .value("Date", day.date, unit: .day),
                                    y: .value("Value", day.value)
                                )
                            }
                            if let chartColor {
                                lineMarks.foregroundStyle(chartColor)
                            } else {
                                lineMarks.foregroundStyle(by: .value("Exercise", singleSeries.name))
                            }
                            if let last = singleSeries.lastByDate {
                                let pointMark = PointMark(
                                    x: .value("Date", last.date, unit: .day),
                                    y: .value("Value", last.value)
                                )
                                if let chartColor {
                                    pointMark.foregroundStyle(chartColor)
                                } else {
                                    pointMark.foregroundStyle(by: .value("Exercise", singleSeries.name))
                                }
                            }
                        } else {
                            let barMarks = ForEach(singleSeries.sortedByDate) { day in
                                BarMark(
                                    x: .value("Date", day.date, unit: .day),
                                    yStart: .value("Value", 0),
                                    yEnd: .value("Value", day.value)
                                )
                            }
                            if let chartColor {
                                barMarks.foregroundStyle(chartColor)
                            } else {
                                barMarks.foregroundStyle(by: .value("Exercise", singleSeries.name))
                            }
                        }
                    }
                }
            }
            .scrollableAndMagnifiable(state: scrollZoomState)
            .chartXScale(domain: xAxisDomain)
            .autoYScale(
                series: series,
                scrollZoomState: scrollZoomState,
                metrics: $visibleMetrics,
                yDomainIncludesZero: chartType == .bar || chartType == .stackedBar,
                isStackedBar: chartType == .stackedBar
            )
            .onAppear {
                if !hasInitialized && !series.isEmpty {
                    initializeScrollPosition()
                    hasInitialized = true
                }
            }
            .onChange(of: seriesSignature) { _, _ in
                if !hasInitialized && !series.isEmpty {
                    initializeScrollPosition()
                    hasInitialized = true
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: xStrideComponent, count: 1)) { value in
                    AxisTick()
//                    AxisGridLine()
                    AxisValueLabel(centered: true) {
                        if let date = value.as(Date.self) {
                            Text(date, format: xAxisLabelFormat)
                        }
                    }
                }
            }
            
            timeRangePicker
        }
        .padding(.horizontal, 2)
    }
    
    @ViewBuilder
    private var headerView: some View {
        if chartType == .stackedBar {
            macrosHeaderView
        } else {
            standardHeaderView
        }
    }

    private var standardHeaderView: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text("Average")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text(formatValue(visibleMetrics.average))
                    Text(unitLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }

    private var macrosHeaderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                if let protein = visibleMetrics.averageProtein {
                    Text("Protein: \(formatValue(protein))g")
                        .font(.subheadline)
                }
                if let carbs = visibleMetrics.averageCarbs {
                    Text("Carbs: \(formatValue(carbs))g")
                        .font(.subheadline)
                }
                if let fats = visibleMetrics.averageFat {
                    Text("Fat: \(formatValue(fats))g")
                        .font(.subheadline)
                }
                if visibleMetrics.averageProtein == nil, visibleMetrics.averageCarbs == nil, visibleMetrics.averageFat == nil {
                    Text("--")
                        .font(.subheadline)
                }
            }
            Text(dateRangeText)
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(.horizontal)
    }
    
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
    
    var xAxisLabelFormat: Date.FormatStyle {
        switch xStrideComponent {
        case .month:
            return .dateTime.month(.abbreviated)
        default:
            return .dateTime.month(.abbreviated).day(.defaultDigits)
        }
    }
    
    private var xAxisDomain: ClosedRange<Date> {
        // Find the earliest and latest dates across all series (using sorted data for consistency)
        let allDates = series.flatMap { $0.sortedByDate.map { $0.date } }
        guard let earliest = allDates.min(),
              let latest = allDates.max() else {
            // Fallback: last year to now
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date.now) ?? Date.now
            return oneYearAgo...Date.now
        }
        
        // Extend 4 days into the past and future
        let fourDaysInSeconds: TimeInterval = 4 * 24 * 60 * 60
        let extendedEarliest = earliest.addingTimeInterval(-fourDaysInSeconds)
        let extendedLatest = latest.addingTimeInterval(fourDaysInSeconds)
        
        return extendedEarliest...extendedLatest
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
        
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .onChange(of: selectedTimeRange) { _, newRange in
            applyTimeRange(newRange)
        }
    }
    
    private func applyTimeRange(_ range: TimeRange) {
        let days: Double
        if let rangeDays = range.days {
            days = rangeDays
        } else {
            days = totalDataDays
        }
        
        scrollZoomState.currentZoomDays = 0
        scrollZoomState.totalZoomDays = scrollZoomState.clampZoomDays(days)
        
        // Scroll so the most recent data is at the right edge
        let allDates = series.flatMap { $0.sortedByDate.map { $0.date } }
        guard let latest = allDates.max() else { return }
        let futureBuffer: TimeInterval = 4 * 86400
        let visibleLength = scrollZoomState.visibleDomainLength
        scrollZoomState.scrollPosition = latest.addingTimeInterval(futureBuffer - visibleLength)
    }
    
    private var totalDataDays: Double {
        let allDates = series.flatMap { $0.sortedByDate.map { $0.date } }
        guard let earliest = allDates.min(), let latest = allDates.max() else { return 365 }
        let days = latest.timeIntervalSince(earliest) / 86400
        return max(days + 8, 7)
    }
    
    private func initializeScrollPosition() {
        let allDates = series.flatMap { $0.sortedByDate.map { $0.date } }
        guard let latest = allDates.max() else { return }
        let futureBuffer: TimeInterval = 4 * 86400
        let visibleLength = scrollZoomState.visibleDomainLength
        scrollZoomState.scrollPosition = latest.addingTimeInterval(futureBuffer - visibleLength)
    }
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case oneWeek = "1W"
        case oneMonth = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case oneYear = "1Y"
        case all = "All"
        
        var id: String { rawValue }
        
        var days: Double? {
            switch self {
            case .oneWeek: return 7
            case .oneMonth: return 30
            case .threeMonths: return 90
            case .sixMonths: return 180
            case .oneYear: return 365
            case .all: return nil
            }
        }
    }
    
    enum ChartType {
        case line
        case bar
        case stackedBar
    }

    struct VisibleMetrics {
        var startDate: Date?
        var endDate: Date?
        var average: Double?
        var delta: Double?
        var averageProtein: Double?
        var averageCarbs: Double?
        var averageFat: Double?

        static let empty = VisibleMetrics(
            startDate: nil,
            endDate: nil,
            average: nil,
            delta: nil,
            averageProtein: nil,
            averageCarbs: nil,
            averageFat: nil
        )
    }
}

#Preview("Line Chart") {
    NewHistoryChart(series: TimeSeriesData.lastYear, yAxisSuffix: " kg")
        .frame(height: 400)
}

#Preview("Bar Chart") {
    NewHistoryChart(series: TimeSeriesData.lastYear, yAxisSuffix: " kg", chartType: NewHistoryChart.ChartType.bar)
}
