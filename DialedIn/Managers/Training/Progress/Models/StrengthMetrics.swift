//
//  StrengthMetrics.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

struct StrengthMetrics: Codable, Equatable {
    let personalRecords: [PersonalRecord]
    let estimatedOneRepMaxes: [String: Double] // exerciseId: 1RM in kg
    let strengthProgressionRate: Double // percentage increase per week
    let period: DateInterval
    
    enum CodingKeys: String, CodingKey {
        case personalRecords = "personal_records"
        case estimatedOneRepMaxes = "estimated_one_rep_maxes"
        case strengthProgressionRate = "strength_progression_rate"
        case period
    }
    
    static var empty: StrengthMetrics {
        StrengthMetrics(
            personalRecords: [],
            estimatedOneRepMaxes: [:],
            strengthProgressionRate: 0,
            period: DateInterval(start: .now, end: .now)
        )
    }
}

struct PersonalRecord: Codable, Equatable, Identifiable {
    let id: String
    let exerciseId: String
    let exerciseName: String
    let weight: Double // kg
    let reps: Int
    let date: Date
    let previousRecord: Double?
    let improvement: Double? // percentage improvement
    
    enum CodingKeys: String, CodingKey {
        case id
        case exerciseId = "exercise_id"
        case exerciseName = "exercise_name"
        case weight
        case reps
        case date
        case previousRecord = "previous_record"
        case improvement
    }
    
    init(
        id: String = UUID().uuidString,
        exerciseId: String,
        exerciseName: String,
        weight: Double,
        reps: Int,
        date: Date,
        previousRecord: Double? = nil,
        improvement: Double? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.date = date
        self.previousRecord = previousRecord
        self.improvement = improvement
    }
    
    var estimatedOneRepMax: Double {
        // Brzycki formula: 1RM = weight × (36 / (37 - reps))
        weight * (36.0 / (37.0 - Double(reps)))
    }
    
    static var mock: PersonalRecord {
        PersonalRecord(
            exerciseId: "1",
            exerciseName: "Bench Press",
            weight: 100,
            reps: 5,
            date: .now,
            previousRecord: 95,
            improvement: 5.26
        )
    }
}

struct StrengthProgression: Equatable {
    let exerciseId: String
    let exerciseName: String
    let dataPoints: [StrengthDataPoint]
    let startingWeight: Double
    let currentWeight: Double
    let percentageGain: Double
}

struct StrengthDataPoint: Identifiable, Equatable {
    let id: String
    let date: Date
    let weight: Double
    let reps: Int
    let estimatedOneRepMax: Double
    
    init(date: Date, weight: Double, reps: Int) {
        self.id = "\(date.ISO8601Format())-\(weight)-\(reps)"
        self.date = date
        self.weight = weight
        self.reps = reps
        // Brzycki formula
        self.estimatedOneRepMax = weight * (36.0 / (37.0 - Double(reps)))
    }
}
