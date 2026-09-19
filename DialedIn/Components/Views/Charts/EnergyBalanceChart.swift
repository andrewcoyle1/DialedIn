//
//  EnergyBalanceChart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/02/2026.
//

import SwiftUI
import Charts

struct EnergyBalanceChart: View {

    let expenditure: TimeSeries
    let energyIntake: TimeSeries

    /// When set, only the last N days are shown (with 1 extra expenditure point for line extension). When nil, all data is shown with scroll/zoom.
    var maxVisibleDays: Int?

    @State private var scrollZoomState = ChartScrollZoomState(
        initialVisibleDays: 7,
        config: ChartScrollZoomState.Configuration(maxZoomDays: 365)
    )
    @State private var visibleMetrics: NewHistoryChart.VisibleMetrics = .empty
    @State private var selectedTimeRange: EnergyBalanceTimeRange = .oneWeek
    @State private var hasInitialized = false

    // MARK: - Derived data
    //
    // These were computed properties read from `body`, which re-evaluates on every frame of a scroll
    // or pinch. `xAxisDomain`, `totalDataDays` and `initializeScrollPosition` each concatenated both
    // display arrays and mapped them to dates before taking min/max — three fresh arrays per frame.
    // They are now computed once, in `init`.

    private let expenditureDisplayData: [TimeSeriesDatapoint]
    private let energyIntakeDisplayData: [TimeSeriesDatapoint]
    private let allSeries: [TimeSeries]
    private let xAxisDomain: ClosedRange<Date>
    private let latestDate: Date?
    private let totalDataDays: Double
    private let dataSignature: Int

    init(
        expenditure: TimeSeries,
        energyIntake: TimeSeries,
        maxVisibleDays: Int? = 7
    ) {
        self.expenditure = expenditure
        self.energyIntake = energyIntake
        self.maxVisibleDays = maxVisibleDays
        self.allSeries = [expenditure, energyIntake]
        self.dataSignature = expenditure.data.count * 1000 + energyIntake.data.count

        // `sortedByDate` is cached on `TimeSeries`; the window is its tail.
        let expenditurePoints: [TimeSeriesDatapoint]
        let intakePoints: [TimeSeriesDatapoint]
        if let limit = maxVisibleDays {
            // One extra expenditure point so the line extends to the edge of the window.
            expenditurePoints = Array(expenditure.sortedByDate.suffix(limit + 1))
            intakePoints = Array(energyIntake.sortedByDate.suffix(limit))
        } else {
            expenditurePoints = expenditure.sortedByDate
            intakePoints = energyIntake.sortedByDate
        }
        self.expenditureDisplayData = expenditurePoints
        self.energyIntakeDisplayData = intakePoints

        // Both arrays are sorted, so the extremes are their first and last elements — no need to
        // concatenate and scan.
        let earliest = [expenditurePoints.first?.date, intakePoints.first?.date]
            .compactMap { $0 }
            .min()
        let latest = [expenditurePoints.last?.date, intakePoints.last?.date]
            .compactMap { $0 }
            .max()
        self.latestDate = latest

        if let earliest, let latest {
            let padding: TimeInterval = 4 * 24 * 60 * 60
            self.xAxisDomain = earliest.addingTimeInterval(-padding)...latest.addingTimeInterval(padding)
            self.totalDataDays = latest.timeIntervalSince(earliest) / 86400
        } else {
            let fallback = Date()
            self.xAxisDomain = fallback...fallback
            self.totalDataDays = 90
        }
    }

    private var xStrideComponent: Calendar.Component {
        let days = scrollZoomState.visibleDomainLength / 86400
        switch days {
        case 51...:
            return .month
        case 10...:
            return .weekOfYear
        default:
            return .day
        }
    }

    private var xAxisLabelFormat: Date.FormatStyle {
        switch xStrideComponent {
        case .month:
            return .dateTime.month(.abbreviated)
        default:
            return .dateTime.month(.abbreviated).day(.defaultDigits)
        }
    }

    private func initializeScrollPosition() {
        guard let latest = latestDate else { return }
        let futureBuffer: TimeInterval = 4 * 86400
        let visibleLength = scrollZoomState.visibleDomainLength
        scrollZoomState.scrollPosition = latest.addingTimeInterval(futureBuffer - visibleLength)
    }

    private func applyTimeRange(_ range: EnergyBalanceTimeRange) {
        let days: Double
        if let rangeDays = range.days {
            days = rangeDays
        } else {
            days = totalDataDays
        }
        scrollZoomState.currentZoomDays = 0
        scrollZoomState.totalZoomDays = scrollZoomState.clampZoomDays(days)
        guard let latest = latestDate else { return }
        let futureBuffer: TimeInterval = 4 * 86400
        let visibleLength = scrollZoomState.visibleDomainLength
        scrollZoomState.scrollPosition = latest.addingTimeInterval(futureBuffer - visibleLength)
    }

    private var dateRangeText: String {
        guard let start = visibleMetrics.startDate,
              let end = visibleMetrics.endDate else {
            return "--"
        }
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .dayOfYear) {
            return end.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year())
        } else if Calendar.current.isDate(start, equalTo: end, toGranularity: .month) {
            return "\(start.formatted(.dateTime.day(.defaultDigits))) - \(end.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year()))"
        } else {
            return "\(start.formatted(.dateTime.month(.abbreviated).day(.defaultDigits))) - \(end.formatted(.dateTime.month(.abbreviated).day(.defaultDigits).year()))"
        }
    }

    enum EnergyBalanceTimeRange: String, CaseIterable, Identifiable {
        case oneWeek = "1W"
        case oneMonth = "1M"
        case threeMonths = "3M"
        case all = "All"

        var id: String { rawValue }

        var days: Double? {
            switch self {
            case .oneWeek: return 7
            case .oneMonth: return 30
            case .threeMonths: return 90
            case .all: return nil
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if maxVisibleDays == nil {
                scrollableHeaderView
            }

            chartContent

            if maxVisibleDays == nil {
                timeRangePicker
            }
        }
        .padding(.horizontal, maxVisibleDays == nil ? 2 : 0)
    }

    @ViewBuilder
    private var scrollableHeaderView: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text("Average")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text(formatValue(visibleMetrics.average))
                    Text("kcal")
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
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }

    private func formatValue(_ value: Double?, showSign: Bool = false) -> String {
        guard let value else { return "--" }
        let formatted = String(format: "%.1f", value)
        return showSign && value >= 0 ? "+\(formatted)" : formatted
    }

    private var chartContent: some View {
        Group {
            if maxVisibleDays == nil {
                scrollableChart
            } else {
                compactChart
            }
        }
    }

    private var compactChart: some View {
        Chart {
            chartMarks
        }
        .chartXScale(domain: xAxisDomain)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }

    private var scrollableChart: some View {
        Chart {
            chartMarks
        }
        .scrollableAndMagnifiable(state: scrollZoomState)
        .chartXScale(domain: xAxisDomain)
        .autoYScale(
            series: allSeries,
            seriesSignature: dataSignature,
            scrollZoomState: scrollZoomState,
            metrics: $visibleMetrics,
            yDomainIncludesZero: true
        )
        .onAppear {
            if !hasInitialized && !expenditureDisplayData.isEmpty {
                initializeScrollPosition()
                hasInitialized = true
            }
        }
        .onChange(of: dataSignature) { _, _ in
            if !hasInitialized && !expenditureDisplayData.isEmpty {
                initializeScrollPosition()
                hasInitialized = true
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: xStrideComponent, count: 1)) { value in
                AxisTick()
                AxisValueLabel(centered: true) {
                    if let date = value.as(Date.self) {
                        Text(date, format: xAxisLabelFormat)
                    }
                }
            }
        }
        .chartLegend(.automatic)
    }

    @ChartContentBuilder
    private var chartMarks: some ChartContent {
        ForEach(energyIntakeDisplayData) { data in
            BarMark(
                x: .value("Date", data.date, unit: .day),
                y: .value("Value", data.value)
            )
        }
        .foregroundStyle(by: .value("Series", energyIntake.name))

        ForEach(expenditureDisplayData) { data in
            LineMark(
                x: .value("Date", data.date, unit: .day),
                y: .value("Value", data.value)
            )
        }
        .foregroundStyle(by: .value("Series", expenditure.name))
    }

    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(EnergyBalanceTimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .onChange(of: selectedTimeRange) { _, newRange in
            applyTimeRange(newRange)
        }
    }
}

#Preview {
    EnergyBalanceChart(
        expenditure: TimeSeries.last14Days,
        energyIntake: TimeSeries.last14Days
    )
    .frame(width: 350, height: 200)
}
