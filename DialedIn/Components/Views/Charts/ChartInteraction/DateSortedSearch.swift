import Foundation

enum DateSortedSearch {
    static func visibleRange(
        start: Date,
        end: Date,
        values: [TimeSeriesDatapoint]
    ) -> Range<Int>? {
        guard !values.isEmpty else { return nil }
        let lower = lowerBound(for: start, values: values)
        let upper = upperBound(for: end, values: values)
        guard lower < upper else { return nil }
        return lower..<upper
    }

    /// First index where `date >= value`
    static func lowerBound(for value: Date, values: [TimeSeriesDatapoint]) -> Int {
        var low = 0
        var high = values.count
        while low < high {
            let mid = (low + high) / 2
            if values[mid].date < value {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }

    /// First index where `date > value`
    static func upperBound(for value: Date, values: [TimeSeriesDatapoint]) -> Int {
        var low = 0
        var high = values.count
        while low < high {
            let mid = (low + high) / 2
            if values[mid].date <= value {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
}
