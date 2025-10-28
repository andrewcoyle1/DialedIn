//
//  TrainingPlanServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

protocol TrainingPlanServices {
    var remote: RemoteTrainingPlanService { get }
    var local: LocalTrainingPlanPersistence { get }
}

struct MockTrainingPlanServices: TrainingPlanServices {
    let remote: RemoteTrainingPlanService
    let local: LocalTrainingPlanPersistence
    
    @MainActor
    init(delay: Double = 0, showError: Bool = false, customPlan: TrainingPlan? = nil) {
        self.remote = MockTrainingPlanService(delay: delay, showError: showError)
        self.local = MockTrainingPlanPersistence(showError: showError, customPlan: customPlan)
    }
}

struct ProductionTrainingPlanServices: TrainingPlanServices {
    let remote: RemoteTrainingPlanService
    let local: LocalTrainingPlanPersistence
    
    @MainActor
    init() {
        self.remote = FirebaseTrainingPlanService()
        self.local = SwiftTrainingPlanPersistence()
    }
}
