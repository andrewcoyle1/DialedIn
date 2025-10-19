//
//  ProductionLocalTrainingAnalyticsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProductionLocalTrainingAnalyticsService: LocalTrainingAnalyticsService {
    private let analytics: ProgressAnalyticsService
    
    init(workoutSessionManager: WorkoutSessionManager, exerciseTemplateManager: ExerciseTemplateManager) {
        self.analytics = ProgressAnalyticsService(
            workoutSessionManager: workoutSessionManager,
            exerciseTemplateManager: exerciseTemplateManager
        )
    }
    
    func getProgressSnapshot(for period: DateInterval) async throws -> ProgressSnapshot {
        try await analytics.getProgressSnapshot(for: period)
    }
    
    func getVolumeTrend(for period: DateInterval, interval: Calendar.Component) async -> VolumeTrend {
        await analytics.getVolumeTrend(for: period, interval: interval)
    }
    
    func getStrengthProgression(for exerciseId: String, in period: DateInterval) async throws -> StrengthProgression? {
        try await analytics.getStrengthProgression(for: exerciseId, in: period)
    }
}
