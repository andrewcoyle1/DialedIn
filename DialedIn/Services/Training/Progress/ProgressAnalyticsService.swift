//
//  ProgressAnalyticsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

@Observable
class ProgressAnalyticsService {
    
    private let workoutSessionManager: WorkoutSessionManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    
    private(set) var cachedSnapshot: ProgressSnapshot?
    private var lastCacheTime: Date?
    private let cacheLifetime: TimeInterval = 300 // 5 minutes
    
    init(workoutSessionManager: WorkoutSessionManager, exerciseTemplateManager: ExerciseTemplateManager) {
        self.workoutSessionManager = workoutSessionManager
        self.exerciseTemplateManager = exerciseTemplateManager
    }
    
    // MARK: - Main Progress Snapshot
    
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot {
        // Check cache
        if let cached = cachedSnapshot,
           let lastCache = lastCacheTime,
           Date().timeIntervalSince(lastCache) < cacheLifetime,
           cached.period == period {
            return cached
        }
        
        let sessions = await getCompletedSessions(in: period)
        
        let volumeMetrics = try await calculateVolumeMetrics(sessions: sessions, period: period)
        let strengthMetrics = try await calculateStrengthMetrics(sessions: sessions, period: period)
        let performanceMetrics = await calculatePerformanceMetrics(sessions: sessions, period: period)
        
        let snapshot = ProgressSnapshot(
            volumeMetrics: volumeMetrics,
            strengthMetrics: strengthMetrics,
            performanceMetrics: performanceMetrics,
            period: period
        )
        
        cachedSnapshot = snapshot
        lastCacheTime = .now
        
        return snapshot
    }
    
    // MARK: - Volume Calculations
    
    func calculateVolumeMetrics(sessions: [WorkoutSessionModel], period: DateInterval) async throws -> VolumeMetrics {
        var totalVolume: Double = 0
        var totalSets: Int = 0
        var totalReps: Int = 0
        var volumeByMuscleGroup: [MuscleGroup: Double] = [:]
        var volumeByExercise: [String: Double] = [:]
        
        for session in sessions {
            for exercise in session.exercises {
                // Get exercise template for muscle groups
                let template = try await exerciseTemplateManager.getExerciseTemplate(id: exercise.templateId)
                
                for set in exercise.sets where set.completedAt != nil && !set.isWarmup {
                    let reps = Double(set.reps ?? 0)
                    let weight = set.weightKg ?? 0
                    let volume = reps * weight
                    
                    totalVolume += volume
                    totalSets += 1
                    totalReps += Int(reps)
                    
                    // By exercise
                    volumeByExercise[exercise.templateId, default: 0] += volume
                    
                    // By muscle group
                    for muscleGroup in template.muscleGroups {
                        volumeByMuscleGroup[muscleGroup, default: 0] += volume
                    }
                }
            }
        }
        
        let averageVolume = sessions.isEmpty ? 0 : totalVolume / Double(sessions.count)
        
        return VolumeMetrics(
            totalVolume: totalVolume,
            totalSets: totalSets,
            totalReps: totalReps,
            averageVolumePerWorkout: averageVolume,
            volumeByMuscleGroup: volumeByMuscleGroup,
            volumeByExercise: volumeByExercise,
            period: period
        )
    }
    
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component = .weekOfYear) async -> VolumeTrend {
        let sessions = await getCompletedSessions(in: period)
        let calendar = Calendar.current
        
        // Group sessions by interval
        var volumeByInterval: [Date: Double] = [:]
        
        for session in sessions {
            let intervalStart = calendar.dateInterval(of: interval, for: session.dateCreated)?.start ?? session.dateCreated
            
            var sessionVolume: Double = 0
            for exercise in session.exercises {
                for set in exercise.sets where set.completedAt != nil && !set.isWarmup {
                    let reps = Double(set.reps ?? 0)
                    let weight = set.weightKg ?? 0
                    sessionVolume += reps * weight
                }
            }
            
            volumeByInterval[intervalStart, default: 0] += sessionVolume
        }
        
        // Create data points
        let dataPoints = volumeByInterval.map { date, volume in
            VolumeDataPoint(date: date, volume: volume)
        }.sorted { $0.date < $1.date }
        
        let averageVolume = dataPoints.isEmpty ? 0 : dataPoints.map { $0.volume }.reduce(0, +) / Double(dataPoints.count)
        
        // Determine trend
        let trendDirection: VolumeTrend.TrendDirection
        let percentageChange: Double
        
        if dataPoints.count >= 2 {
            let firstHalf = dataPoints.prefix(dataPoints.count / 2)
            let secondHalf = dataPoints.suffix(dataPoints.count / 2)
            
            let firstAvg = firstHalf.map { $0.volume }.reduce(0, +) / Double(firstHalf.count)
            let secondAvg = secondHalf.map { $0.volume }.reduce(0, +) / Double(secondHalf.count)
            
            percentageChange = firstAvg > 0 ? ((secondAvg - firstAvg) / firstAvg) * 100 : 0
            
            if percentageChange > 5 {
                trendDirection = .increasing
            } else if percentageChange < -5 {
                trendDirection = .decreasing
            } else {
                trendDirection = .stable
            }
        } else {
            trendDirection = .stable
            percentageChange = 0
        }
        
        return VolumeTrend(
            dataPoints: dataPoints,
            averageVolume: averageVolume,
            trendDirection: trendDirection,
            percentageChange: percentageChange
        )
    }
    
    // MARK: - Strength Calculations
    
    private struct ExerciseMax {
        let weight: Double
        let reps: Int
        let date: Date
    }
    
    func calculateStrengthMetrics(sessions: [WorkoutSessionModel], period: DateInterval) async throws -> StrengthMetrics {
        var exerciseMaxes: [String: ExerciseMax] = [:]
        var previousRecords: [String: Double] = [:]
        
        // Get all personal bests in period
        for session in sessions {
            for exercise in session.exercises {
                let exerciseId = exercise.templateId
                
                for set in exercise.sets where set.completedAt != nil && !set.isWarmup {
                    let weight = set.weightKg ?? 0
                    let reps = set.reps ?? 0
                    
                    if reps > 0 && weight > 0 {
                        let estimated1RM = weight * (36.0 / (37.0 - Double(reps)))
                        
                        if let current = exerciseMaxes[exerciseId] {
                            let currentEstimated = current.weight * (36.0 / (37.0 - Double(current.reps)))
                            if estimated1RM > currentEstimated {
                                previousRecords[exerciseId] = currentEstimated
                                exerciseMaxes[exerciseId] = ExerciseMax(weight: weight, reps: reps, date: session.dateCreated)
                            }
                        } else {
                            exerciseMaxes[exerciseId] = ExerciseMax(weight: weight, reps: reps, date: session.dateCreated)
                        }
                    }
                }
            }
        }
        
        // Convert to PersonalRecord objects
        var personalRecords: [PersonalRecord] = []
        var estimated1RMs: [String: Double] = [:]
        
        for (exerciseId, maxData) in exerciseMaxes {
            let template = try await exerciseTemplateManager.getExerciseTemplate(id: exerciseId)
            let exerciseName = template.name
            
            let estimated1RM = maxData.weight * (36.0 / (37.0 - Double(maxData.reps)))
            estimated1RMs[exerciseId] = estimated1RM
            
            let previousRecord = previousRecords[exerciseId]
            let improvement = previousRecord != nil ? ((estimated1RM - previousRecord!) / previousRecord!) * 100 : nil
            
            let personalRecord = PersonalRecord(
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                weight: maxData.weight,
                reps: maxData.reps,
                date: maxData.date,
                previousRecord: previousRecord,
                improvement: improvement
            )
            personalRecords.append(personalRecord)
        }
        
        // Calculate progression rate
        let progressionRate = calculateStrengthProgressionRate(sessions: sessions)
        
        return StrengthMetrics(
            personalRecords: personalRecords.sorted { $0.date > $1.date },
            estimatedOneRepMaxes: estimated1RMs,
            strengthProgressionRate: progressionRate,
            period: period
        )
    }
    
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression? {
        let sessions = await getCompletedSessions(in: period)
        
        var dataPoints: [StrengthDataPoint] = []
        
        for session in sessions {
            for exercise in session.exercises where exercise.templateId == exerciseId {
                // Get the heaviest set
                if let heaviestSet = exercise.sets
                    .filter({ $0.completedAt != nil && ($0.weightKg ?? 0) > 0 })
                    .max(by: { ($0.weightKg ?? 0) < ($1.weightKg ?? 0) }) {
                    
                    let dataPoint = StrengthDataPoint(
                        date: session.dateCreated,
                        weight: heaviestSet.weightKg ?? 0,
                        reps: heaviestSet.reps ?? 0
                    )
                    dataPoints.append(dataPoint)
                }
            }
        }
        
        guard !dataPoints.isEmpty else { return nil }
        
        dataPoints.sort { $0.date < $1.date }
        
        let startingWeight = dataPoints.first!.estimatedOneRepMax
        let currentWeight = dataPoints.last!.estimatedOneRepMax
        let percentageGain = ((currentWeight - startingWeight) / startingWeight) * 100
        
        let template = try await exerciseTemplateManager.getExerciseTemplate(id: exerciseId)
        
        return StrengthProgression(
            exerciseId: exerciseId,
            exerciseName: template.name,
            dataPoints: dataPoints,
            startingWeight: startingWeight,
            currentWeight: currentWeight,
            percentageGain: percentageGain
        )
    }
    
    private func calculateStrengthProgressionRate(sessions: [WorkoutSessionModel]) -> Double {
        // Simplified: compare first week vs last week average 1RM
        guard sessions.count >= 2 else { return 0 }
        
        let sorted = sessions.sorted { $0.dateCreated < $1.dateCreated }
        let midpoint = sorted.count / 2
        
        let firstHalf = Array(sorted.prefix(midpoint))
        let secondHalf = Array(sorted.suffix(midpoint))
        
        let firstAvg = averageEstimated1RM(from: firstHalf)
        let secondAvg = averageEstimated1RM(from: secondHalf)
        
        guard firstAvg > 0 else { return 0 }
        
        return ((secondAvg - firstAvg) / firstAvg) * 100
    }
    
    private func averageEstimated1RM(from sessions: [WorkoutSessionModel]) -> Double {
        var total: Double = 0
        var count = 0
        
        for session in sessions {
            for exercise in session.exercises {
                for set in exercise.sets where set.completedAt != nil {
                    let weight = set.weightKg ?? 0
                    let reps = set.reps ?? 0
                    if reps > 0 && weight > 0 {
                        let estimated = weight * (36.0 / (37.0 - Double(reps)))
                        total += estimated
                        count += 1
                    }
                }
            }
        }
        
        return count > 0 ? total / Double(count) : 0
    }
    
    // MARK: - Performance Calculations
    
    func calculatePerformanceMetrics(sessions: [WorkoutSessionModel], period: DateInterval) async -> PerformanceMetrics {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: period.start, to: period.end).day ?? 1
        let weeks = Double(totalDays) / 7.0
        
        let completedSessions = sessions.filter { $0.endedAt != nil }
        let totalWorkouts = completedSessions.count
        let frequency = weeks > 0 ? Double(totalWorkouts) / weeks : 0
        
        // Calculate streaks
        let workoutDates = completedSessions.map { calendar.startOfDay(for: $0.dateCreated) }.sorted()
        let (currentStreak, longestStreak) = calculateStreaks(dates: workoutDates)
        
        // Average duration
        let durations = completedSessions.compactMap { session -> TimeInterval? in
            guard let endedAt = session.endedAt else { return nil }
            return endedAt.timeIntervalSince(session.dateCreated)
        }
        let averageDuration = durations.isEmpty ? 0 : durations.reduce(0, +) / Double(durations.count)
        
        // Rest day pattern
        let workoutDaysOfWeek = Set(completedSessions.map { calendar.component(.weekday, from: $0.dateCreated) })
        let allDays = Set(1...7)
        let restDays = Array(allDays.subtracting(workoutDaysOfWeek)).sorted()
        
        return PerformanceMetrics(
            completionRate: 1.0, // Would need scheduled workouts to calculate properly
            trainingFrequency: frequency,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalWorkouts: totalWorkouts,
            missedWorkouts: 0, // Would need scheduled workouts
            averageWorkoutDuration: averageDuration,
            restDayPattern: restDays,
            period: period
        )
    }
    
    private func calculateStreaks(dates: [Date]) -> (current: Int, longest: Int) {
        guard !dates.isEmpty else { return (0, 0) }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 1
        
        // Check if current streak is active
        if let lastDate = dates.last, calendar.isDate(lastDate, inSameDayAs: today) {
            currentStreak = 1
            
            // Count backwards
            for iteration in stride(from: dates.count - 2, through: 0, by: -1) {
                let daysDiff = calendar.dateComponents([.day], from: dates[iteration], to: dates[iteration + 1]).day ?? 0
                if daysDiff == 1 {
                    currentStreak += 1
                } else {
                    break
                }
            }
        }
        
        // Calculate longest streak
        for iteration in 1..<dates.count {
            let daysDiff = calendar.dateComponents([.day], from: dates[iteration - 1], to: dates[iteration]).day ?? 0
            if daysDiff == 1 {
                tempStreak += 1
                longestStreak = max(longestStreak, tempStreak)
            } else {
                tempStreak = 1
            }
        }
        
        longestStreak = max(longestStreak, tempStreak)
        longestStreak = max(longestStreak, currentStreak)
        
        return (currentStreak, longestStreak)
    }
    
    // MARK: - Helper Methods
    
    private func getCompletedSessions(in period: DateInterval) async -> [WorkoutSessionModel] {
        // This would typically fetch from WorkoutSessionManager
        // For now, return empty array as placeholder
        // In production, you'd call workoutSessionManager.fetchSessions(in: period)
        return []
    }
    
    func invalidateCache() {
        cachedSnapshot = nil
        lastCacheTime = nil
    }
}
