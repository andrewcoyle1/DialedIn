//
//  MockTrainingPlanService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct MockTrainingPlanService: RemoteTrainingPlanService {
    
    let delay: Double
    let showError: Bool
    
    init(delay: Double = 0.0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func saveTrainingPlan(userId: String, plan: TrainingPlan) async throws {
        try tryShowError()
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
}
