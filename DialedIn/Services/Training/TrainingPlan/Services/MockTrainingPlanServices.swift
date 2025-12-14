//
//  MockTrainingPlanServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockTrainingPlanServices: TrainingPlanServices {
    let remote: RemoteTrainingPlanService
    let local: LocalTrainingPlanPersistence
    
    init(delay: Double = 0, showError: Bool = false, plans: [TrainingPlan] = TrainingPlan.mocks) {
        self.remote = MockTrainingPlanService(delay: delay, showError: showError)
        self.local = MockTrainingPlanPersistence(showError: showError, customPlans: plans)
    }
}
