//
//  MuscleGroupSetsAggregator.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import Foundation

/// Aggregates completed sets per muscle group from workout sessions, using exercise templates for muscle mapping.
enum MuscleGroupSetsAggregator {

    /// Returns last 7 days of sets per muscle (index 0 = 7 days ago, index 6 = today) and total sets.
    /// Primary muscles (bool false) contribute full sets; secondary muscles (bool true) contribute at 0.5 factor.
    static func aggregate(
        sessions: [WorkoutSessionModel],
        templates: [String: ExerciseModel],
        calendar: Calendar,
        endDate: Date = Date()
    ) -> [Muscles: (last7Days: [Double], total: Double)] {
        let startOfEnd = calendar.startOfDay(for: endDate)
        guard let day0 = calendar.date(byAdding: .day, value: -6, to: startOfEnd) else {
            return [:]
        }

        var result: [Muscles: (last7Days: [Double], total: Double)] = [:]

        for muscle in Muscles.allCases {
            var last7Days = Array(repeating: 0.0, count: 7)
            var total: Double = 0

            for session in sessions {
                let sessionDate = session.endedAt ?? session.dateCreated
                let day = calendar.startOfDay(for: sessionDate)

                for exercise in session.exercises {
                    guard let template = templates[exercise.templateId] else { continue }
                    guard let isSecondary = template.muscleGroups[muscle] else { continue }

                    let completedSets = exercise.sets
                        .filter { !$0.isWarmup && $0.completedAt != nil }
                        .count

                    if completedSets > 0 {
                        let factor: Double = isSecondary ? 0.5 : 1.0
                        let weightedSets = Double(completedSets) * factor
                        total += weightedSets
                        for iteration in 0..<7 {
                            guard let dateForDay = calendar.date(byAdding: .day, value: iteration, to: day0) else { continue }
                            if calendar.isDate(day, inSameDayAs: dateForDay) {
                                last7Days[iteration] += weightedSets
                                break
                            }
                        }
                    }
                }
            }

            result[muscle] = (last7Days, total)
        }

        return result
    }
}
