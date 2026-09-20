import Foundation

struct ChartYDomainCalculator {
    struct Configuration {
        let rangePaddingPercent: Double
        let minValuePaddingPercent: Double
        let minimumPadding: Double
    }

    struct NiceScale {
        let tickValues: [Double]
        let domain: ClosedRange<Double>
    }

    static func paddedDomain(
        for values: [Double],
        config: Configuration
    ) -> ClosedRange<Double> {
        guard let minValue = values.min(), let maxValue = values.max() else {
            return 0...1
        }
        return paddedDomain(minValue: minValue, maxValue: maxValue, config: config)
    }

    static func paddedDomain(
        minValue: Double,
        maxValue: Double,
        config: Configuration
    ) -> ClosedRange<Double> {
        guard minValue.isFinite, maxValue.isFinite else {
            return 0...1
        }
        let range = maxValue - minValue
        let padding = max(
            range * config.rangePaddingPercent,
            max(abs(minValue) * config.minValuePaddingPercent, config.minimumPadding)
        )
        var yMin = minValue - padding
        var yMax = maxValue + padding
        if yMin == yMax {
            yMin -= 1
            yMax += 1
        }
        return yMin...yMax
    }

    /// Computes a nice tick-aligned domain with at most `maxTicks` ticks.
    /// The returned domain's lower and upper bounds are the first and last tick values,
    /// so they align exactly with the edges of the chart.
    static func niceScale(
        minValue: Double,
        maxValue: Double,
        maxTicks: Int = 6
    ) -> NiceScale {
        guard minValue.isFinite, maxValue.isFinite else {
            return NiceScale(tickValues: [0, 1], domain: 0...1)
        }

        var low = minValue
        var high = maxValue
        if low == high {
            low -= 1
            high += 1
        }

        let rawRange = high - low
        let niceRange = niceNumber(rawRange, round: false)
        let tickSpacing = niceNumber(niceRange / Double(maxTicks - 1), round: true)
        let niceMin = floor(low / tickSpacing) * tickSpacing
        let niceMax = ceil(high / tickSpacing) * tickSpacing

        var ticks: [Double] = []
        var tick = niceMin
        // Use a small epsilon to avoid floating-point issues at the boundary
        while tick <= niceMax + tickSpacing * 0.01 {
            ticks.append(tick)
            tick += tickSpacing
        }

        // Safety: trim if floating-point drift produced an extra tick
        if ticks.count > maxTicks, let last = ticks.last, last > niceMax + tickSpacing * 0.5 {
            ticks.removeLast()
        }

        guard let first = ticks.first, let last = ticks.last else {
            return NiceScale(tickValues: [0, 1], domain: 0...1)
        }

        return NiceScale(tickValues: ticks, domain: first...last)
    }

    /// Rounds a positive value to a "nice" number (1, 2, 5 × 10^n).
    private static func niceNumber(_ value: Double, round: Bool) -> Double {
        guard value > 0 else { return 1 }
        let exponent = floor(log10(value))
        let fraction = value / pow(10, exponent)
        let niceFraction: Double
        if round {
            if fraction < 1.5 {
                niceFraction = 1
            } else if fraction < 3 {
                niceFraction = 2
            } else if fraction < 7 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        } else {
            if fraction <= 1 {
                niceFraction = 1
            } else if fraction <= 2 {
                niceFraction = 2
            } else if fraction <= 5 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        }
        return niceFraction * pow(10, exponent)
    }
}
