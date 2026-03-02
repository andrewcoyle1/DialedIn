//
//  ExerciseDetailEntry.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import Foundation

/// Represents daily estimated 1-RM for a specific exercise for list display.
struct ExerciseDetailEntry: Identifiable {
    let id: String
    let date: Date
    let oneRMKg: Double
}

extension ExerciseDetailEntry: @MainActor MetricEntry {
    var displayLabel: String {
        "\(date.formatted(.dateTime.day().month().year()))"
    }

    var displayValue: String {
        "\(oneRMKg.formatted(.number.precision(.fractionLength(1)))) kg"
    }

    var systemImageName: String {
        "dumbbell.fill"
    }

    func timeSeriesData() -> [MetricTimeSeriesPoint] {
        [MetricTimeSeriesPoint(seriesName: "1-RM", date: date, value: oneRMKg)]
    }
}
