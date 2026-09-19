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
    
    let series: [TimeSeries]
    var yAxisSuffix: String = ""
    var chartType: ChartType = .line
    var chartColor: Color?

    // MARK: - Derived data
    //
    // Everything below is a pure function of `series`, and was previously a computed property read
    // from `body`. `body` re-evaluates on every frame of a scroll or pinch — `scrollZoomState` is
    // `@Observable` and `visibleMetrics` is `@State` — so each of these ran 60-120 times a second,
    // allocating a fresh array over every datapoint each time. They are now computed once, in
    // `init`, which runs only when the parent supplies new series.

    private let stackedBarDays: [StackedBarDay]
    /// The series actually plotted: the last year of each, as a slice of the already-sorted array.
    private let plottedSeries: [PlottedSeries]
    private let xAxisDomain: ClosedRange<Date>
    private let latestDate: Date?
    private let totalDataDays: Double
    private let seriesSignature: Int

    init(
        series: [TimeSeries],
        yAxisSuffix: String = "",
        chartType: ChartType = .line,
        chartColor: Color? = nil
    ) {
        self.series = series
        self.yAxisSuffix = yAxisSuffix
        self.chartType = chartType
        self.chartColor = chartColor

        let derived = DerivedData(series: series, chartType: chartType)
        self.stackedBarDays = derived.stackedBarDays
        self.plottedSeries = derived.plottedSeries
        self.xAxisDomain = derived.xAxisDomain
        self.latestDate = derived.latestDate
        self.totalDataDays = derived.totalDataDays
        self.seriesSignature = derived.signature
    }

    /// A series windowed to the plotted range. `points` is a slice of `TimeSeries.sortedByDate`, so
    /// windowing costs a binary search and copies nothing.
    private struct PlottedSeries: Identifiable {
        let id: String
        let name: String
        let points: ArraySlice<TimeSeriesDatapoint>
        let last: TimeSeriesDatapoint?
    }

    private struct MacroTotals {
        var protein: Double = 0
        var carbs: Double = 0
        var fat: Double = 0
    }

    private struct StackedBarDay {
        let date: Date
        let protein: Double
        let carbs: Double
        let fat: Double
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            
            Chart {
                if chartType == .stackedBar, series.count >= 3 {
                    ForEach(stackedBarDays, id: \.date) { day in
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
                    ForEach(plottedSeries) { singleSeries in
                        if chartType == .line {
                            let lineMarks = ForEach(singleSeries.points) { day in
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
                            if let last = singleSeries.last {
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
                            let barMarks = ForEach(singleSeries.points) { day in
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
                seriesSignature: seriesSignature,
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
        guard let latest = latestDate else { return }
        let futureBuffer: TimeInterval = 4 * 86400
        let visibleLength = scrollZoomState.visibleDomainLength
        scrollZoomState.scrollPosition = latest.addingTimeInterval(futureBuffer - visibleLength)
    }
    
    private func initializeScrollPosition() {
        guard let latest = latestDate else { return }
        let futureBuffer: TimeInterval = 4 * 86400
        let visibleLength = scrollZoomState.visibleDomainLength
        scrollZoomState.scrollPosition = latest.addingTimeInterval(futureBuffer - visibleLength)
    }
    
    // MARK: - Derived Data

    /// One pass over the series, producing everything `body` used to recompute per frame.
    ///
    /// The old `xAxisDomain` and `totalDataDays` each ran `series.flatMap { $0.sortedByDate.map(\.date) }`
    /// — allocating a fresh array over every datapoint — and `stackedBarDayData` built a dictionary
    /// and sorted its keys. This walks each series once and allocates nothing per frame.
    private struct DerivedData {
        let stackedBarDays: [StackedBarDay]
        let plottedSeries: [PlottedSeries]
        let xAxisDomain: ClosedRange<Date>
        let latestDate: Date?
        let totalDataDays: Double
        let signature: Int

        init(series: [TimeSeries], chartType: ChartType) {
            // The plotted window. `MetricDetailView` used to build this by filtering and then
            // constructing a fresh `TimeSeries` per series on every one of its body evaluations —
            // and `TimeSeries.init` sorts. `sortedByDate` is already sorted, so the same window is
            // a binary search and a slice.
            let cutoff = Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .distantPast

            var plotted: [PlottedSeries] = []
            plotted.reserveCapacity(series.count)
            var earliest: Date?
            var latest: Date?
            var hasher = Hasher()

            for item in series {
                hasher.combine(item.id)
                hasher.combine(item.data.count)
                if let last = item.sortedByDate.last {
                    hasher.combine(last.date)
                }

                let sorted = item.sortedByDate
                let startIndex = DateSortedSearch.lowerBound(for: cutoff, values: sorted)
                let points = sorted[startIndex...]
                plotted.append(
                    PlottedSeries(
                        id: item.id,
                        name: item.name,
                        points: points,
                        last: points.last
                    )
                )

                if let first = points.first {
                    earliest = min(earliest ?? first.date, first.date)
                }
                if let last = points.last {
                    latest = max(latest ?? last.date, last.date)
                }
            }

            self.plottedSeries = plotted
            self.latestDate = latest
            self.signature = hasher.finalize()

            // Four days of breathing room either side, so the newest point is not flush to the edge.
            let buffer: TimeInterval = 4 * 86400
            if let earliest, let latest {
                self.xAxisDomain = earliest.addingTimeInterval(-buffer)...latest.addingTimeInterval(buffer)
                self.totalDataDays = max(latest.timeIntervalSince(earliest) / 86400 + 8, 7)
            } else {
                let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now
                self.xAxisDomain = oneYearAgo...Date.now
                self.totalDataDays = 365
            }

            // Only the macros chart draws these, and building them means a dictionary over every
            // point — it used to run for any chart with three or more series, line charts included.
            self.stackedBarDays = chartType == .stackedBar
                ? Self.stackedBarDays(from: plotted)
                : []
        }

        /// Macros only: protein, carbs and fat merged into one row per day.
        private static func stackedBarDays(from series: [PlottedSeries]) -> [StackedBarDay] {
            guard series.count >= 3 else { return [] }

            var byDate: [Date: MacroTotals] = [:]
            byDate.reserveCapacity(series[0].points.count)
            for point in series[0].points {
                byDate[point.date, default: MacroTotals()].protein = point.value
            }
            for point in series[1].points {
                byDate[point.date, default: MacroTotals()].carbs = point.value
            }
            for point in series[2].points {
                byDate[point.date, default: MacroTotals()].fat = point.value
            }

            return byDate.keys.sorted().map { date in
                let totals = byDate[date] ?? MacroTotals()
                return StackedBarDay(
                    date: date,
                    protein: totals.protein,
                    carbs: totals.carbs,
                    fat: totals.fat
                )
            }
        }
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
    NewHistoryChart(series: TimeSeries.lastYear, yAxisSuffix: " kg")
        .frame(height: 400)
}

#Preview("Bar Chart") {
    NewHistoryChart(series: TimeSeries.lastYear, yAxisSuffix: " kg", chartType: NewHistoryChart.ChartType.bar)
}
