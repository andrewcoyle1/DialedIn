//
//  LocalGoalService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

protocol LocalGoalService {
    func cacheGoal(_ goal: WeightGoal) async throws
    func getCachedGoal(id: String, userId: String) async throws -> WeightGoal?
    func getCachedActiveGoal(userId: String) async throws -> WeightGoal?
    func clearCache(userId: String) async throws
}
