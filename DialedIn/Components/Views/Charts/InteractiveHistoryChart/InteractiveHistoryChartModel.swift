import SwiftUI

@Observable
@MainActor
final class InteractiveHistoryChartModel {
    struct SeriesVisibleMetrics {
        let seriesID: String
        let averageValue: Double?
        let startValue: Double?
        let endValue: Double?
        let delta: Double?
    }

    struct VisibleRangeMetrics {
        let startDate: Date
        let endDate: Date
        let perSeries: [SeriesVisibleMetrics]
    }

    struct Configuration {
        var secondsPerDay: Double = 86400
        var minZoomDays: Double = 3
        var maxZoomDays: Double = 180
        var yAxisDebounce: Duration = .milliseconds(50)
        var yAxisRangePaddingPercent: Double = 0.1
        var yAxisMinValuePaddingPercent: Double = 0.05
        var yAxisMinimumPadding: Double = 0.5
        var minVisiblePoints: Int = 200
        var fallbackVisiblePoints: Int = 300
    }

    private(set) var series: [TimeSeriesData.TimeSeries]
    private(set) var dataVersion: Int = 0
    let scrollZoomState: ChartScrollZoomState
    var yMin: Double = 0
    var yMax: Double = 1

    @ObservationIgnored private var yAxisUpdateTask: Task<Void, Never>?
    @ObservationIgnored var onVisibleMetricsChange: ((VisibleRangeMetrics) -> Void)?

    private var cachedAllValues: [TimeSeriesDatapoint] = []
    private var cachedDownsampledBySeries: [String: [TimeSeriesDatapoint]] = [:]
    private var cachedVisibleMetrics: VisibleRangeMetrics?
    private var didInitialize = false
    private let config: Configuration

    init(
        series: [TimeSeriesData.TimeSeries],
        initialVisibleDays: Double,
        config: Configuration = .init()
    ) {
        self.series = series
        self.config = config
        self.scrollZoomState = ChartScrollZoomState(
            initialVisibleDays: initialVisibleDays,
            config: .init(
                secondsPerDay: config.secondsPerDay,
                minZoomDays: config.minZoomDays,
                maxZoomDays: config.maxZoomDays
            )
        )
        self.scrollZoomState.onVisibleRangeChanged = { [weak self] in
            self?.scheduleYAxisUpdate()
        }
        rebuildAllValues()
        updateDataVersion()
    }

    var visibleDomainLength: TimeInterval {
        scrollZoomState.visibleDomainLength
    }

    var xStrideComponent: Calendar.Component {
        switch visibleDomainLength / config.secondsPerDay {
        case 91...:
            return .month
        case 31...:
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

    var xDomain: ClosedRange<Date>? {
        guard let first = cachedAllValues.first, let last = cachedAllValues.last else { return nil }
        return first.date...last.date
    }

    var yDomain: ClosedRange<Double> {
        yMin...yMax
    }

    func formatYAxisValue(_ value: Double, suffix: String?) -> String {
        let number = value.formatted()
        if let suffix, !suffix.isEmpty {
            return number + suffix
        }
        return number
    }

    func updateSeries(_ newSeries: [TimeSeriesData.TimeSeries]) {
        series = newSeries
        updateDataVersion()
        rebuildAllValues()
        cachedDownsampledBySeries = [:]
        cachedVisibleMetrics = nil
        didInitialize = false
        initializeIfNeeded()
    }

    func updatePlotWidth(_ width: CGFloat) {
        scrollZoomState.updatePlotWidth(width)
    }

    func visibleSeriesData(for series: TimeSeriesData.TimeSeries) -> [TimeSeriesDatapoint] {
        cachedDownsampledBySeries[series.id] ?? []
    }

    func initializeIfNeeded() {
        guard !didInitialize else { return }
        guard let first = cachedAllValues.first, let last = cachedAllValues.last else { return }
        scrollZoomState.totalZoomDays = scrollZoomState.clampZoomDays(scrollZoomState.totalZoomDays)
        let desiredStart = last.date.addingTimeInterval(-visibleDomainLength)
        scrollZoomState.scrollPosition = maxDate(desiredStart, first.date)
        updateVisibleRangeCaches()
        didInitialize = true
    }

    func scheduleYAxisUpdate() {
        yAxisUpdateTask?.cancel()
        yAxisUpdateTask = Task { @MainActor in
            try? await Task.sleep(for: config.yAxisDebounce)
            guard !Task.isCancelled else { return }
            updateVisibleRangeCaches()
        }
    }

    func visibleRangeMetrics() -> VisibleRangeMetrics {
        if let cachedVisibleMetrics {
            return cachedVisibleMetrics
        }
        return rebuildVisibleSeriesCache()
    }

    private var maxVisiblePoints: Int {
        let widthBased = Int(scrollZoomState.plotWidth.rounded())
        return max(
            config.minVisiblePoints,
            widthBased > 0 ? widthBased : config.fallbackVisiblePoints
        )
    }

    private func rebuildAllValues() {
        cachedAllValues = series
            .flatMap { $0.data }
            .sorted { $0.date < $1.date }
    }

    private func rebuildVisibleSeriesCache() -> VisibleRangeMetrics {
        let (startDate, endDate) = visibleDateRange()
        var perSeriesMetrics: [SeriesVisibleMetrics] = []
        var downsampledBySeries: [String: [TimeSeriesDatapoint]] = [:]

        for series in series {
            let values = series.sortedByDate
            guard let range = DateSortedSearch.visibleRange(
                start: startDate,
                end: endDate,
                values: values
            ) else {
                downsampledBySeries[series.id] = []
                continue
            }

            let extendedLower = max(range.lowerBound - 1, 0)
            let extendedUpper = min(range.upperBound + 1, values.count)
            let visible = Array(values[extendedLower..<extendedUpper])
            downsampledBySeries[series.id] = ChartDownsampler.minMax(
                data: visible,
                maxPoints: maxVisiblePoints
            )

            let slice = values[range]
            let average = slice.isEmpty
                ? nil
                : slice.reduce(0) { $0 + $1.value } / Double(slice.count)
            let startValue = slice.first?.value
            let endValue = slice.last?.value
            let delta = (startValue != nil && endValue != nil) ? endValue! - startValue! : nil
            perSeriesMetrics.append(
                SeriesVisibleMetrics(
                    seriesID: series.id,
                    averageValue: average,
                    startValue: startValue,
                    endValue: endValue,
                    delta: delta
                )
            )
        }

        let metrics = VisibleRangeMetrics(
            startDate: startDate,
            endDate: endDate,
            perSeries: perSeriesMetrics
        )
        cachedDownsampledBySeries = downsampledBySeries
        cachedVisibleMetrics = metrics
        return metrics
    }

    private func visibleDateRange() -> (start: Date, end: Date) {
        let start = scrollZoomState.scrollPosition
        let end = scrollZoomState.scrollPosition.addingTimeInterval(visibleDomainLength)
        return (start, end)
    }

    private func updateVisibleRangeCaches() {
        updateYAxisForVisibleRange()
        let metrics = rebuildVisibleSeriesCache()
        onVisibleMetricsChange?(metrics)
    }

    private func updateYAxisForVisibleRange() {
        let (start, end) = visibleDateRange()
        guard let range = DateSortedSearch.visibleRange(
            start: start,
            end: end,
            values: cachedAllValues
        ) else {
            setMinMax(for: cachedAllValues.map(\.value))
            return
        }

        var minValue = Double.greatestFiniteMagnitude
        var maxValue = -Double.greatestFiniteMagnitude
        for element in cachedAllValues[range] {
            minValue = min(minValue, element.value)
            maxValue = max(maxValue, element.value)
        }
        setMinMax(minValue: minValue, maxValue: maxValue)
    }

    private func setMinMax(for values: [Double]) {
        let domain = ChartYDomainCalculator.paddedDomain(
            for: values,
            config: yDomainConfig
        )
        yMin = domain.lowerBound
        yMax = domain.upperBound
    }

    private func setMinMax(minValue: Double, maxValue: Double) {
        let domain = ChartYDomainCalculator.paddedDomain(
            minValue: minValue,
            maxValue: maxValue,
            config: yDomainConfig
        )
        yMin = domain.lowerBound
        yMax = domain.upperBound
    }

    private var yDomainConfig: ChartYDomainCalculator.Configuration {
        .init(
            rangePaddingPercent: config.yAxisRangePaddingPercent,
            minValuePaddingPercent: config.yAxisMinValuePaddingPercent,
            minimumPadding: config.yAxisMinimumPadding
        )
    }

    private func updateDataVersion() {
        dataVersion = series.reduce(0) { $0 &+ $1.data.count }
    }

    private func maxDate(_ lhs: Date, _ rhs: Date) -> Date {
        lhs > rhs ? lhs : rhs
    }
}
