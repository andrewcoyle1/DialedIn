//
//  TrainingAnalyticsServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import Foundation

protocol TrainingAnalyticsServices {
    var remote: RemoteTrainingAnalyticsService { get }
    var local: LocalTrainingAnalyticsService { get }
}

struct MockTrainingAnalyticsServices: TrainingAnalyticsServices {
    let remote: RemoteTrainingAnalyticsService
    let local: LocalTrainingAnalyticsService
    
    init(delay: Double = 0, showError: Bool = false) {
        self.remote = MockRemoteTrainingAnalyticsService()
        self.local = MockLocalTrainingAnalyticsService(delay: delay, showError: showError)
    }
}

struct ProductionTrainingAnalyticsServices: TrainingAnalyticsServices {
    let remote: RemoteTrainingAnalyticsService
    let local: LocalTrainingAnalyticsService
    
    init(workoutSessionManager: WorkoutSessionManager, exerciseTemplateManager: ExerciseTemplateManager) {
        self.remote = ProductionRemoteTrainingAnalyticsService()
        self.local = ProductionLocalTrainingAnalyticsService(workoutSessionManager: workoutSessionManager, exerciseTemplateManager: exerciseTemplateManager)
    }
}
