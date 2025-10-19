//
//  PerformanceMetrics.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

struct PerformanceMetrics: Codable, Equatable {
    let completionRate: Double // 0-1
    let trainingFrequency: Double // workouts per week
    let currentStreak: Int // consecutive days
    let longestStreak: Int
    let totalWorkouts: Int
    let missedWorkouts: Int
    let averageWorkoutDuration: TimeInterval // seconds
    let restDayPattern: [Int] // days of week typically rested
    let period: DateInterval
    
    enum CodingKeys: String, CodingKey {
        case completionRate = "completion_rate"
        case trainingFrequency = "training_frequency"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case totalWorkouts = "total_workouts"
        case missedWorkouts = "missed_workouts"
        case averageWorkoutDuration = "average_workout_duration"
        case restDayPattern = "rest_day_pattern"
        case period
    }
    
    init(
        completionRate: Double,
        trainingFrequency: Double,
        currentStreak: Int,
        longestStreak: Int,
        totalWorkouts: Int,
        missedWorkouts: Int,
        averageWorkoutDuration: TimeInterval,
        restDayPattern: [Int],
        period: DateInterval
    ) {
        self.completionRate = completionRate
        self.trainingFrequency = trainingFrequency
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalWorkouts = totalWorkouts
        self.missedWorkouts = missedWorkouts
        self.averageWorkoutDuration = averageWorkoutDuration
        self.restDayPattern = restDayPattern
        self.period = period
    }
    
    var adherencePercentage: Double {
        completionRate * 100
    }
    
    var averageDurationFormatted: String {
        let minutes = Int(averageWorkoutDuration / 60)
        return "\(minutes)m"
    }
    
    static var empty: PerformanceMetrics {
        PerformanceMetrics(
            completionRate: 0,
            trainingFrequency: 0,
            currentStreak: 0,
            longestStreak: 0,
            totalWorkouts: 0,
            missedWorkouts: 0,
            averageWorkoutDuration: 0,
            restDayPattern: [],
            period: DateInterval(start: .now, end: .now)
        )
    }
    
    static var mock: PerformanceMetrics {
        PerformanceMetrics(
            completionRate: 0.85,
            trainingFrequency: 4.2,
            currentStreak: 12,
            longestStreak: 28,
            totalWorkouts: 48,
            missedWorkouts: 8,
            averageWorkoutDuration: 3600, // 60 minutes
            restDayPattern: [1, 4], // Sunday, Wednesday
            period: DateInterval(start: Calendar.current.date(byAdding: .month, value: -3, to: .now) ?? .now, end: .now)
        )
    }
}

struct ConsistencyStreak: Equatable {
    let streakLength: Int
    let startDate: Date
    let endDate: Date?
    let isActive: Bool
}
