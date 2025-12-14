//
//  MockTrainingPlanPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation

class MockTrainingPlanPersistence: LocalTrainingPlanPersistence {
    
    var showError: Bool
    private var plans: [String: TrainingPlan] = [:]
    
    init(showError: Bool = false, customPlans: [TrainingPlan] = TrainingPlan.mocks) {
        self.showError = showError
        
        // Seed with mock data
        for plan in customPlans {
            plans[plan.planId] = plan
        }
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func getCurrentTrainingPlan() -> TrainingPlan? {
        plans.values.first { $0.isActive }
    }
    
    func getAllPlans() -> [TrainingPlan] {
        Array(plans.values).sorted { $0.createdAt > $1.createdAt }
    }
    
    func getPlan(id: String) -> TrainingPlan? {
        plans[id]
    }
    
    func savePlan(_ plan: TrainingPlan) throws {
        try tryShowError()
        plans[plan.planId] = plan
    }
    
    func deletePlan(id: String) throws {
        try tryShowError()
        plans.removeValue(forKey: id)
    }
    
    // Legacy method for backwards compatibility
    func saveTrainingPlan(plan: TrainingPlan) throws {
        try savePlan(plan)
    }
}
