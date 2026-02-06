import Foundation

enum ChartDownsampler {
    static func minMax(
        data: [TimeSeriesDatapoint],
        maxPoints: Int
    ) -> [TimeSeriesDatapoint] {
        guard data.count > maxPoints, maxPoints > 2 else { return data }
        let targetBuckets = max(1, maxPoints / 2)
        let bucketSize = max(1, Int(ceil(Double(data.count) / Double(targetBuckets))))
        var indices: Set<Int> = [0, data.count - 1]

        var bucketStart = 0
        while bucketStart < data.count {
            let bucketEnd = min(bucketStart + bucketSize, data.count)
            var minIndex = bucketStart
            var maxIndex = bucketStart
            var minValue = data[bucketStart].value
            var maxValue = data[bucketStart].value
            if bucketStart + 1 < bucketEnd {
                for idx in (bucketStart + 1)..<bucketEnd {
                    let value = data[idx].value
                    if value < minValue {
                        minValue = value
                        minIndex = idx
                    }
                    if value > maxValue {
                        maxValue = value
                        maxIndex = idx
                    }
                }
            }
            indices.insert(minIndex)
            indices.insert(maxIndex)
            bucketStart = bucketEnd
        }

        let sortedIndices = indices.sorted()
        return sortedIndices.map { data[$0] }
    }
}
