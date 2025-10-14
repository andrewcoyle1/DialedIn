//
//  MockNutritionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import Foundation

@MainActor
class MockNutritionPersistence: LocalNutritionPersistence {
    
    var showError: Bool
    private var storedPlan: DietPlan?

    init(showError: Bool = false) {
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func getCurrentDietPlan() -> DietPlan? {
        storedPlan
    }
    
    func saveDietPlan(plan: DietPlan) throws {
        try tryShowError()
        storedPlan = plan
    }
}
