//
//  MockTrainingPlanPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation

@MainActor
class MockTrainingPlanPersistence: LocalTrainingPlanPersistence {
    
    var showError: Bool
    private var storedPlan: TrainingPlan?
    
    init(showError: Bool = false) {
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func getCurrentTrainingPlan() -> TrainingPlan? {
        storedPlan
    }
    
    func saveTrainingPlan(plan: TrainingPlan) throws {
        try tryShowError()
        storedPlan = plan
    }
}
