//
//  MockNutritionService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct MockNutritionService: RemoteNutritionService {
    
    let plan: DietPlan?
    let delay: Double
    let showError: Bool
    
    init(plan: DietPlan? = .mock, delay: Double = 0.0, showError: Bool = false) {
        self.plan = plan
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func saveDietPlan(userId: String, plan: DietPlan) async throws {
        try tryShowError()
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
}
