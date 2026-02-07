//
//  ExerciseOneRMAggregator.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import Foundation

/// Aggregates estimated 1-RM per exercise (by templateId) from workout sessions.
/// Uses Epley formula: 1RM = weight * (1 + reps/30) for weight+reps sets.
enum ExerciseOneRMAggregator {

    /// Returns last 7 days of estimated 1-RM (kg) per exercise keyed by templateId.
    /// For each day, uses the max estimated 1-RM from all completed sets.
    /// `latest1RM` is the best 1-RM across the 7-day window.
    static func aggregate(
        sessions: [WorkoutSessionModel],
        calendar: Calendar,
        endDate: Date = Date()
    ) -> [String: (name: String, last7Days: [Double], latest1RM: Double)] {
        let startOfEnd = calendar.startOfDay(for: endDate)
        guard let day0 = calendar.date(byAdding: .day, value: -6, to: startOfEnd) else {
            return [:]
        }

        var result: [String: (name: String, last7Days: [Double], latest1RM: Double)] = [:]

        for session in sessions {
            let sessionDate = session.endedAt ?? session.dateCreated
            let day = calendar.startOfDay(for: sessionDate)

            for exercise in session.exercises {
                let templateId = exercise.templateId
                let name = exercise.name

                let best1RMForDay = exercise.sets
                    .filter { !$0.isWarmup && $0.completedAt != nil }
                    .compactMap { set -> Double? in
                        guard let weight = set.weightKg, weight > 0 else { return nil }
                        let reps = set.reps ?? 1
                        return estimated1RM(weightKg: weight, reps: max(1, reps))
                    }
                    .max()

                if let oneRM = best1RMForDay, oneRM > 0 {
                    var current = result[templateId] ?? (name: name, last7Days: Array(repeating: 0.0, count: 7), latest1RM: 0)
                    for iteration in 0..<7 {
                        guard let dateForDay = calendar.date(byAdding: .day, value: iteration, to: day0) else { continue }
                        if calendar.isDate(day, inSameDayAs: dateForDay) {
                            current.last7Days[iteration] = max(current.last7Days[iteration], oneRM)
                            break
                        }
                    }
                    current.latest1RM = max(current.latest1RM, oneRM)
                    result[templateId] = current
                }
            }
        }

        return result
    }

    /// Epley formula: 1RM = weight * (1 + reps/30). Public for reuse in detail presenters.
    static func estimated1RM(weightKg: Double, reps: Int) -> Double {
        guard reps >= 1 else { return weightKg }
        if reps == 1 { return weightKg }
        return weightKg * (1 + Double(reps) / 30)
    }
}
