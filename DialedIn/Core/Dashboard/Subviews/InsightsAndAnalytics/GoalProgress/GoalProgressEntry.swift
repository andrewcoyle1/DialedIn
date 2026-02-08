//
//  GoalProgressEntry.swift
//  DialedIn
//

import Foundation

/// Represents a weight entry with progress toward target weight at that date.
struct GoalProgressEntry: Identifiable {
    let id: String
    let date: Date
    let weightKg: Double
    let progressPercent: Double
}

extension GoalProgressEntry: @MainActor MetricEntry {
    var displayLabel: String {
        date.formatted(.dateTime.day().month().year())
    }

    var displayValue: String {
        "\(weightKg.formatted(.number.precision(.fractionLength(1)))) kg (\(Int(progressPercent))%)"
    }

    var systemImageName: String {
        "scalemass"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "Progress", date: date, value: progressPercent)]
    }
}
