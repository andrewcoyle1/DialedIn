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
    private var storedPlans: [String: TrainingPlan] = [:]
    
    init(delay: Double = 0.0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    private func simulateDelay() async throws {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    func fetchAllPlans() async throws -> [TrainingPlan] {
        try tryShowError()
        try await simulateDelay()
        return Array(storedPlans.values).sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchPlan(id: String) async throws -> TrainingPlan {
        try tryShowError()
        try await simulateDelay()
        guard let plan = storedPlans[id] else {
            throw TrainingPlanError.invalidData
        }
        return plan
    }
    
    func createPlan(_ plan: TrainingPlan) async throws {
        try tryShowError()
        try await simulateDelay()
        // Note: Can't mutate struct, this would need to be a class
        // or use an actor for state management
    }
    
    func updatePlan(_ plan: TrainingPlan) async throws {
        try tryShowError()
        try await simulateDelay()
    }
    
    func deletePlan(id: String) async throws {
        try tryShowError()
        try await simulateDelay()
    }
    
    // Legacy method
    func saveTrainingPlan(userId: String, plan: TrainingPlan) async throws {
        try await createPlan(plan)
    }
}
