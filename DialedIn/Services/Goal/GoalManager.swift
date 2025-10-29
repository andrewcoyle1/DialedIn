//
//  GoalManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

@Observable
class GoalManager {
    private let remote: RemoteGoalService
    private let local: LocalGoalService
    
    private(set) var currentGoal: WeightGoal?
    private(set) var goalHistory: [WeightGoal] = []
    private(set) var isLoading: Bool = false
    
    init(services: GoalServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    // MARK: - Public Methods
    
    /// Create a new goal with the current weight as starting weight
    func createGoal(
        userId: String,
        objective: String,
        startingWeightKg: Double,
        targetWeightKg: Double,
        weeklyChangeKg: Double
    ) async throws -> WeightGoal {
        isLoading = true
        defer { isLoading = false }
        
        let goal = WeightGoal(
            userId: userId,
            objective: objective,
            startingWeightKg: startingWeightKg,
            targetWeightKg: targetWeightKg,
            weeklyChangeKg: weeklyChangeKg,
            status: .active
        )
        
        // Save to remote
        try await remote.createGoal(goal)
        
        // Cache locally
        try await local.cacheGoal(goal)
        
        // Update local state
        currentGoal = goal
        
        return goal
    }
    
    /// Get the active goal for the user
    @discardableResult
    func getActiveGoal(userId: String) async throws -> WeightGoal? {
        isLoading = true
        defer { isLoading = false }
        
        // Try local cache first
        if let cached = try? await local.getCachedActiveGoal(userId: userId) {
            currentGoal = cached
            return cached
        }
        
        // Fetch from remote
        let goal = try await remote.getActiveGoal(userId: userId)
        
        // Cache it
        if let goal = goal {
            try? await local.cacheGoal(goal)
        }
        
        currentGoal = goal
        return goal
    }
    
    /// Get all goals for the user (including past goals)
    func getAllGoals(userId: String) async throws -> [WeightGoal] {
        isLoading = true
        defer { isLoading = false }
        
        let goals = try await remote.getAllGoals(userId: userId)
        
        // Cache active goal
        if let activeGoal = goals.first(where: { $0.status == .active }) {
            try? await local.cacheGoal(activeGoal)
            currentGoal = activeGoal
        }
        
        goalHistory = goals
        return goals
    }
    
    /// Mark a goal as completed
    func completeGoal(goalId: String, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await remote.updateGoalStatus(goalId: goalId, userId: userId, status: .completed)
        
        // Clear current goal if it was the active one
        if currentGoal?.goalId == goalId {
            currentGoal = nil
            try? await local.clearCache(userId: userId)
        }
    }
    
    /// Mark a goal as abandoned
    func abandonGoal(goalId: String, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await remote.updateGoalStatus(goalId: goalId, userId: userId, status: .abandoned)
        
        // Clear current goal if it was the active one
        if currentGoal?.goalId == goalId {
            currentGoal = nil
            try? await local.clearCache(userId: userId)
        }
    }
    
    /// Pause a goal
    func pauseGoal(goalId: String, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await remote.updateGoalStatus(goalId: goalId, userId: userId, status: .paused)
        
        // Clear current goal if it was the active one
        if currentGoal?.goalId == goalId {
            currentGoal = nil
            try? await local.clearCache(userId: userId)
        }
    }
    
    /// Delete a goal
    func deleteGoal(goalId: String, userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await remote.deleteGoal(goalId: goalId, userId: userId)
        
        // Clear from local state
        if currentGoal?.goalId == goalId {
            currentGoal = nil
        }
        goalHistory.removeAll { $0.goalId == goalId }
        
        // Clear cache
        try? await local.clearCache(userId: userId)
    }
    
    // MARK: - Testing Helper
    
    /// Set current goal directly (for previews and testing only)
    func setCurrentGoalForTesting(_ goal: WeightGoal?) {
        currentGoal = goal
    }
}
