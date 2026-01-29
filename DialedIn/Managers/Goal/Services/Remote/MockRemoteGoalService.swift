//
//  MockRemoteGoalService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct MockRemoteGoalService: RemoteGoalService {
    let delay: Double
    let showError: Bool
    
    private var mockGoals: [WeightGoal] = WeightGoal.mocks
    
    init(delay: Double = 0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw NSError(domain: "MockGoalError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
    }
    
    func createGoal(_ goal: WeightGoal) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // In production, this would persist to Firestore
    }
    
    func getGoal(id: String, userId: String) async throws -> WeightGoal {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        
        guard let goal = mockGoals.first(where: { $0.goalId == id }) else {
            throw NSError(domain: "MockGoalError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Goal not found"])
        }
        return goal
    }
    
    func getActiveGoal(userId: String) async throws -> WeightGoal? {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        
        return mockGoals.first(where: { $0.status == .active })
    }
    
    func getAllGoals(userId: String) async throws -> [WeightGoal] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        
        return mockGoals.sorted { $0.createdAt > $1.createdAt }
    }
    
    func updateGoalStatus(goalId: String, userId: String, status: WeightGoal.GoalStatus) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // In production, this would update Firestore
    }
    
    func deleteGoal(goalId: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        try tryShowError()
        // In production, this would delete from Firestore
    }
}
