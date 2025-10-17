//
//  TrainingPlanManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation

@Observable
class TrainingPlanManager {
    
    private let local: LocalTrainingPlanPersistence
    private let remote: RemoteTrainingPlanService
    private(set) var currentTrainingPlan: TrainingPlan?
    
    init(services: TrainingPlanServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentTrainingPlan = local.getCurrentTrainingPlan()
    }
    
}
