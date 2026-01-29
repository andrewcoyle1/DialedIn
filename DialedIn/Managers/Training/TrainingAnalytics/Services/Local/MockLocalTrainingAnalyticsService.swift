//
//  MockLocalTrainingAnalyticsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct MockLocalTrainingAnalyticsService: LocalTrainingAnalyticsService {
    
    var delay: Double
    var showError: Bool
    
    init(delay: Double = 0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private struct WorkoutStats {
        let workoutsPerWeek: Double
        let totalWorkouts: Int
        let averageVolumePerWorkout: Double
        let totalVolume: Double
        let totalSets: Int
        let totalReps: Int
    }

    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        let calendar = Calendar.current
        let days = max(1, calendar.dateComponents([.day], from: period.start, to: period.end).day ?? 1)
        let weeks = Double(days) / 7.0

        let workoutStats = computeWorkoutStats(days: days, weeks: weeks)
        let volume = makeVolumeMetrics(stats: workoutStats, period: period)

        let prCount = determinePRCount(days: days)
        let personalRecords = generatePersonalRecords(prCount: prCount, period: period)
        let strength = makeStrengthMetrics(personalRecords: personalRecords, days: days, period: period)

        let performance = makePerformanceMetrics(
            weeks: weeks,
            workoutsPerWeek: workoutStats.workoutsPerWeek,
            totalWorkouts: workoutStats.totalWorkouts,
            period: period
        )

        return ProgressSnapshot(
            volumeMetrics: volume,
            strengthMetrics: strength,
            performanceMetrics: performance,
            period: period
        )
    }

    private func computeWorkoutStats(days: Int, weeks: Double) -> WorkoutStats {
        let workoutsPerWeek = 3.2
        let totalWorkouts = Int((workoutsPerWeek * weeks).rounded())
        let averageVolumePerWorkout = 2800.0
        let totalVolume = averageVolumePerWorkout * Double(max(totalWorkouts, 1))
        let totalSets = totalWorkouts * 18
        let totalReps = totalWorkouts * 18 * 10
        return WorkoutStats(
            workoutsPerWeek: workoutsPerWeek,
            totalWorkouts: totalWorkouts,
            averageVolumePerWorkout: averageVolumePerWorkout,
            totalVolume: totalVolume,
            totalSets: totalSets,
            totalReps: totalReps
        )
    }

    private func makeVolumeMetrics(
        stats: WorkoutStats,
        period: DateInterval
    ) -> VolumeMetrics {
        let volumeByMuscleGroup: [MuscleGroup: Double] = [
            .chest: stats.totalVolume * 0.25,
            .back: stats.totalVolume * 0.25,
            .legs: stats.totalVolume * 0.3,
            .shoulders: stats.totalVolume * 0.12,
            .arms: stats.totalVolume * 0.08
        ]

        let volumeByExercise: [String: Double] = [
            "bench": stats.totalVolume * 0.14,
            "squat": stats.totalVolume * 0.18,
            "deadlift": stats.totalVolume * 0.2
        ]

        return VolumeMetrics(
            totalVolume: stats.totalVolume.rounded(),
            totalSets: stats.totalSets,
            totalReps: stats.totalReps,
            averageVolumePerWorkout: stats.averageVolumePerWorkout,
            volumeByMuscleGroup: volumeByMuscleGroup,
            volumeByExercise: volumeByExercise,
            period: period
        )
    }

    private func determinePRCount(days: Int) -> Int {
        switch days {
        case ..<45: return 3
        case ..<100: return 5
        case ..<200: return 7
        default: return 10
        }
    }

    private func generatePersonalRecords(prCount: Int, period: DateInterval) -> [PersonalRecord] {
        var personalRecords: [PersonalRecord] = []
        let exercises = [("bench", "Bench Press"), ("squat", "Back Squat"), ("deadlift", "Deadlift"), ("ohp", "Overhead Press")]
        for index in 0..<prCount {
            let exercise = exercises[index % exercises.count]
            let fraction = Double(index + 1) / Double(prCount + 1)
            let date = Date(
                timeInterval: period.start.timeIntervalSince1970 + fraction * (period.end.timeIntervalSince1970 - period.start.timeIntervalSince1970),
                since: Date(timeIntervalSince1970: 0)
            )
            let baseWeight: Double
            let reps: Int
            switch exercise.0 {
            case "bench": baseWeight = 85; reps = 5
            case "squat": baseWeight = 140; reps = 3
            case "deadlift": baseWeight = 160; reps = 2
            case "ohp": baseWeight = 55; reps = 5
            default: baseWeight = 80; reps = 5
            }
            let weight = baseWeight + Double(index) * 1.5
            let previous = max(0, weight - 2)
            personalRecords.append(
                PersonalRecord(
                    exerciseId: exercise.0,
                    exerciseName: exercise.1,
                    weight: weight,
                    reps: reps,
                    date: date,
                    previousRecord: previous * (36.0 / (37.0 - Double(reps))),
                    improvement: 100 * ((weight - previous) / max(previous, 1))
                )
            )
        }
        personalRecords.sort { $0.date > $1.date }
        return personalRecords
    }

    private func makeStrengthMetrics(
        personalRecords: [PersonalRecord],
        days: Int,
        period: DateInterval
    ) -> StrengthMetrics {
        var estimatedOneRepMaxes: [String: Double] = [:]
        for personalRecord in personalRecords where estimatedOneRepMaxes[personalRecord.exerciseId] == nil {
            estimatedOneRepMaxes[personalRecord.exerciseId] = personalRecord.estimatedOneRepMax
        }
        return StrengthMetrics(
            personalRecords: personalRecords,
            estimatedOneRepMaxes: estimatedOneRepMaxes,
            strengthProgressionRate: 2.5 + min(6.0, Double(days) / 60.0),
            period: period
        )
    }

    private func makePerformanceMetrics(
        weeks: Double,
        workoutsPerWeek: Double,
        totalWorkouts: Int,
        period: DateInterval
    ) -> PerformanceMetrics {
        return PerformanceMetrics(
            completionRate: 0.8,
            trainingFrequency: workoutsPerWeek,
            currentStreak: min(5, max(1, Int(weeks.rounded()))),
            longestStreak: min(12, Int((weeks * 1.2).rounded())),
            totalWorkouts: totalWorkouts,
            missedWorkouts: max(0, Int((weeks * 0.3).rounded())),
            averageWorkoutDuration: 60 * 60,
            restDayPattern: [2, 5],
            period: period
        )
    }
    
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component) async -> VolumeTrend {
        do {
            try await Task.sleep(for: .seconds(delay))
        } catch {
            
        }
            
        let calendar = Calendar.current
        var date = calendar.dateInterval(of: interval, for: period.start)?.start ?? period.start
        var points: [VolumeDataPoint] = []
        var base: Double = 2_500
        while date < period.end {
            base *= 1.02
            points.append(VolumeDataPoint(date: date, volume: base.rounded()))
            if let next = calendar.date(byAdding: interval, value: 1, to: date) {
                date = next
            } else {
                break
            }
        }
        let avg = points.isEmpty ? 0 : points.map { $0.volume }.reduce(0, +) / Double(points.count)
        return VolumeTrend(
            dataPoints: points,
            averageVolume: avg,
            trendDirection: .increasing,
            percentageChange: 8.4
        )
    }
    
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        let calendar = Calendar.current
        var date = period.start
        var points: [StrengthDataPoint] = []
        var oneRm: Double = 80

        let days = calendar.dateComponents([.day], from: period.start, to: period.end).day ?? 0
        let step: DateComponents
        switch days {
        case ..<45: step = DateComponents(day: 3)
        case ..<100: step = DateComponents(weekOfYear: 1)
        case ..<200: step = DateComponents(weekOfYear: 2)
        default: step = DateComponents(month: 1)
        }

        while date < period.end {
            oneRm += 0.5
            points.append(StrengthDataPoint(date: date, weight: oneRm, reps: 1))
            guard let next = calendar.date(byAdding: step, to: date) else { break }
            date = next
        }
        guard let first = points.first, let last = points.last else { return nil }
        let start = first.estimatedOneRepMax
        let current = last.estimatedOneRepMax
        return StrengthProgression(
            exerciseId: exerciseId,
            exerciseName: exerciseId.capitalized,
            dataPoints: points,
            startingWeight: start,
            currentWeight: current,
            percentageGain: start > 0 ? ((current - start) / start) * 100 : 0
        )
    }
    
}
