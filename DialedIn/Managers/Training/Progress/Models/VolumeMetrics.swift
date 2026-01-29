//
//  VolumeMetrics.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

struct VolumeMetrics: Codable, Equatable {
    let totalVolume: Double // kg
    let totalSets: Int
    let totalReps: Int
    let averageVolumePerWorkout: Double
    let volumeByMuscleGroup: [MuscleGroup: Double]
    let volumeByExercise: [String: Double] // exerciseId: volume
    let period: DateInterval
    
    init(
        totalVolume: Double,
        totalSets: Int,
        totalReps: Int,
        averageVolumePerWorkout: Double,
        volumeByMuscleGroup: [MuscleGroup: Double],
        volumeByExercise: [String: Double],
        period: DateInterval
    ) {
        self.totalVolume = totalVolume
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.averageVolumePerWorkout = averageVolumePerWorkout
        self.volumeByMuscleGroup = volumeByMuscleGroup
        self.volumeByExercise = volumeByExercise
        self.period = period
    }
    
    enum CodingKeys: String, CodingKey {
        case totalVolume = "total_volume"
        case totalSets = "total_sets"
        case totalReps = "total_reps"
        case averageVolumePerWorkout = "average_volume_per_workout"
        case volumeByMuscleGroup = "volume_by_muscle_group"
        case volumeByExercise = "volume_by_exercise"
        case period
    }
    
    static var empty: VolumeMetrics {
        VolumeMetrics(
            totalVolume: 0,
            totalSets: 0,
            totalReps: 0,
            averageVolumePerWorkout: 0,
            volumeByMuscleGroup: [:],
            volumeByExercise: [:],
            period: DateInterval(start: .now, end: .now)
        )
    }
}

struct VolumeDataPoint: Identifiable, Equatable {
    let id: String
    let date: Date
    let volume: Double
    
    init(date: Date, volume: Double) {
        self.id = date.ISO8601Format()
        self.date = date
        self.volume = volume
    }
    
    static var mock: VolumeDataPoint {
        mocks[0]
    }
    
    static var mocks: [VolumeDataPoint] {
        return [
            VolumeDataPoint(
                date: Date.now,
                volume: 5
            ),
            VolumeDataPoint(
                date: Date.now.addingTimeInterval(days: -1),
                volume: 4
            ),
            VolumeDataPoint(
                date: Date.now.addingTimeInterval(days: -2),
                volume: 3
            ),
            VolumeDataPoint(
                date: Date.now.addingTimeInterval(days: -3),
                volume: 2
            ),
            VolumeDataPoint(
                date: Date.now.addingTimeInterval(days: -4),
                volume: 1
            )
        ]
    }
}

struct VolumeTrend: Equatable {
    let dataPoints: [VolumeDataPoint]
    let averageVolume: Double
    let trendDirection: TrendDirection
    let percentageChange: Double
    
    enum TrendDirection {
        case increasing
        case decreasing
        case stable
    }
    
    static var mock: VolumeTrend {
        mocks[0]
    }
    
    static var mocks: [VolumeTrend] {
        return [
            VolumeTrend(
                dataPoints: VolumeDataPoint.mocks,
                averageVolume: 0.5,
                trendDirection: TrendDirection.increasing,
                percentageChange: 2
            ),
            VolumeTrend(
                dataPoints: VolumeDataPoint.mocks,
                averageVolume: 0.5,
                trendDirection: TrendDirection.increasing,
                percentageChange: 2
            ),
            VolumeTrend(
                dataPoints: VolumeDataPoint.mocks,
                averageVolume: 0.5,
                trendDirection: TrendDirection.increasing,
                percentageChange: 2
            ),
            VolumeTrend(
                dataPoints: VolumeDataPoint.mocks,
                averageVolume: 0.5,
                trendDirection: TrendDirection.increasing,
                percentageChange: 2
            ),
            VolumeTrend(
                dataPoints: VolumeDataPoint.mocks,
                averageVolume: 0.5,
                trendDirection: TrendDirection.increasing,
                percentageChange: 2
            )
        ]
    }
}
