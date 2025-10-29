//
//  ProductionTrainingAnalyticsServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionTrainingAnalyticsServices: TrainingAnalyticsServices {
    let remote: RemoteTrainingAnalyticsService
    let local: LocalTrainingAnalyticsService
    
    init(workoutSessionManager: WorkoutSessionManager, exerciseTemplateManager: ExerciseTemplateManager) {
        self.remote = ProductionRemoteTrainingAnalyticsService()
        self.local = ProductionLocalTrainingAnalyticsService(workoutSessionManager: workoutSessionManager, exerciseTemplateManager: exerciseTemplateManager)
    }
}
