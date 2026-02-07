//
//  TimeSeriesDatapoint.swift
//  ArchitectureProject
//
//  Created by Andrew Coyle on 05/02/2026.
//

import SwiftUI

struct TimeSeriesDatapoint: Identifiable {
    let id: String
    let date: Date
    let value: Double
    
    init(id: String = UUID().uuidString, date: Date, value: Double) {
        self.id = id
        self.date = date
        self.value = value
    }
}

struct TimeSeriesData {
    struct TimeSeries: Identifiable {
        /// Series name
        let name: String

        /// Dataset
        let data: [TimeSeriesDatapoint]

        /// Cached sorted data
        let sortedByDate: [TimeSeriesDatapoint]
        let lastByDate: TimeSeriesDatapoint?

        /// The identifier for the series
        var id: String {
            name
        }

        init(name: String, data: [TimeSeriesDatapoint]) {
            self.name = name
            self.data = data
            self.sortedByDate = data.sorted { $0.date < $1.date }
            self.lastByDate = data.max { $0.date < $1.date }
        }
    }

    /// Mock data for demo-ing charts (approx 500 datapoints per series)
    static let last14Days: [TimeSeries] = {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? Date.now
        let days = 14
        return [
            makeSeries(
                name: "Bench Press",
                startDate: startDate,
                days: days,
                base: 85,
                amplitude: 18,
                trendPerDay: 4,
                phase: 0
            ),
            makeSeries(
                name: "Barbell Squat",
                startDate: startDate,
                days: days,
                base: 55,
                amplitude: 22,
                trendPerDay: 5,
                phase: 1.2
            )
        ]
    }()

    /// Mock data for demo-ing charts (approx 500 datapoints per series)
    static let lastYear: [TimeSeries] = {
        let startDate = makeDate(year: 2022, month: 1, day: 1)
        let days = 500
        return [
            makeSeries(
                name: "Bench Press",
                startDate: startDate,
                days: days,
                base: 55,
                amplitude: 18,
                trendPerDay: 0.04,
                phase: 0
            ),
            makeSeries(
                name: "Barbell Squat",
                startDate: startDate,
                days: days,
                base: 85,
                amplitude: 22,
                trendPerDay: 0.05,
                phase: 1.2
            )
        ]
    }()

    /// Mock data for demo-ing charts (approx 500 datapoints per series)
    static let last6Years: [TimeSeries] = {
        let startDate = makeDate(year: 2022, month: 1, day: 1)
        let days = 500
        return [
            makeSeries(
                name: "Bench Press",
                startDate: startDate,
                days: days,
                dayMultiplier: 6,
                base: 55,
                amplitude: 18,
                trendPerDay: 0.04,
                phase: 0
            ),
            makeSeries(
                name: "Barbell Squat",
                startDate: startDate,
                days: days,
                dayMultiplier: 6, 
                base: 85,
                amplitude: 22,
                trendPerDay: 0.05,
                phase: 1.2
            )
        ]
    }()

    static func makeDate(year: Int, month: Int, day: Int = 1) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    private static func makeSeries(
        name: String,
        startDate: Date,
        days: Int,
        dayMultiplier: Int = 1,
        base: Double,
        amplitude: Double,
        trendPerDay: Double,
        phase: Double
    ) -> TimeSeries {
        let calendar = Calendar.current
        let data = (0..<days).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset*dayMultiplier, to: startDate) ?? startDate
            let wave = sin(Double(dayOffset) / 14.0 + phase) * amplitude
            let trend = Double(dayOffset) * trendPerDay
            let value = max(0, base + wave + trend)
            return TimeSeriesDatapoint(date: date, value: value)
        }
        return TimeSeries(name: name, data: data)
    }
}
