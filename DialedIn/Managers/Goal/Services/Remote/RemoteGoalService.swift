//
//  RemoteGoalService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol RemoteGoalService {
    func createGoal(_ goal: WeightGoal) async throws
    func getGoal(id: String, userId: String) async throws -> WeightGoal
    func getActiveGoal(userId: String) async throws -> WeightGoal?
    func getAllGoals(userId: String) async throws -> [WeightGoal]
    func updateGoalStatus(goalId: String, userId: String, status: WeightGoal.GoalStatus) async throws
    func deleteGoal(goalId: String, userId: String) async throws
}
