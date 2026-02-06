import Foundation

struct ChartYDomainCalculator {
    struct Configuration {
        let rangePaddingPercent: Double
        let minValuePaddingPercent: Double
        let minimumPadding: Double
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
}
