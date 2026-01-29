//
//  ProgressSnapshot.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

struct ProgressSnapshot: Codable, Equatable {
    let volumeMetrics: VolumeMetrics
    let strengthMetrics: StrengthMetrics
    let performanceMetrics: PerformanceMetrics
    let capturedAt: Date
    let period: DateInterval
    
    enum CodingKeys: String, CodingKey {
        case volumeMetrics = "volume_metrics"
        case strengthMetrics = "strength_metrics"
        case performanceMetrics = "performance_metrics"
        case capturedAt = "captured_at"
        case period
    }
    
    init(
        volumeMetrics: VolumeMetrics,
        strengthMetrics: StrengthMetrics,
        performanceMetrics: PerformanceMetrics,
        capturedAt: Date = .now,
        period: DateInterval
    ) {
        self.volumeMetrics = volumeMetrics
        self.strengthMetrics = strengthMetrics
        self.performanceMetrics = performanceMetrics
        self.capturedAt = capturedAt
        self.period = period
    }
    
    static var empty: ProgressSnapshot {
        let now = Date()
        let period = DateInterval(start: now, end: now)
        return ProgressSnapshot(
            volumeMetrics: .empty,
            strengthMetrics: .empty,
            performanceMetrics: .empty,
            capturedAt: now,
            period: period
        )
    }
    
    static var mock: ProgressSnapshot {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        let period = DateInterval(start: startDate, end: endDate)
        
        return ProgressSnapshot(
            volumeMetrics: VolumeMetrics(
                totalVolume: 45000,
                totalSets: 240,
                totalReps: 1920,
                averageVolumePerWorkout: 2812.5,
                volumeByMuscleGroup: [
                    .chest: 12000,
                    .back: 15000,
                    .legs: 18000
                ],
                volumeByExercise: [:],
                period: period
            ),
            strengthMetrics: StrengthMetrics(
                personalRecords: [.mock],
                estimatedOneRepMaxes: ["1": 115, "2": 140, "3": 180],
                strengthProgressionRate: 2.5,
                period: period
            ),
            performanceMetrics: .mock,
            capturedAt: .now,
            period: period
        )
    }
}
