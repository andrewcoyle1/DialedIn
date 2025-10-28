//
//  MockNutritionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import Foundation

class MockNutritionPersistence: LocalNutritionPersistence {
    
    var delay: Double
    var showError: Bool
    private var storedPlan: DietPlan?

    init(plan: DietPlan? = .mock, delay: Double = 0, showError: Bool = false) {
        self.storedPlan = plan
        self.delay = delay
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
