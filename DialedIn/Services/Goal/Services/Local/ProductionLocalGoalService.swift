//
//  ProductionLocalGoalService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import Foundation

struct ProductionLocalGoalService: LocalGoalService {
    
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "goals_cache"
    private let activeGoalKey = "active_goal_cache"
    
    private func getCacheKey(userId: String) -> String {
        "\(cacheKey)_\(userId)"
    }
    
    private func getActiveGoalCacheKey(userId: String) -> String {
        "\(activeGoalKey)_\(userId)"
    }
    
    func cacheGoal(_ goal: WeightGoal) async throws {
        // Cache individual goal
        if let encoded = try? JSONEncoder().encode(goal) {
            userDefaults.set(encoded, forKey: "\(getCacheKey(userId: goal.userId))_\(goal.goalId)")
        }
        
        // Cache as active if status is active
        if goal.status == .active {
            if let encoded = try? JSONEncoder().encode(goal) {
                userDefaults.set(encoded, forKey: getActiveGoalCacheKey(userId: goal.userId))
            }
        }
    }
    
    func getCachedGoal(id: String, userId: String) async throws -> WeightGoal? {
        guard let data = userDefaults.data(forKey: "\(getCacheKey(userId: userId))_\(id)"),
              let goal = try? JSONDecoder().decode(WeightGoal.self, from: data) else {
            return nil
        }
        return goal
    }
    
    func getCachedActiveGoal(userId: String) async throws -> WeightGoal? {
        guard let data = userDefaults.data(forKey: getActiveGoalCacheKey(userId: userId)),
              let goal = try? JSONDecoder().decode(WeightGoal.self, from: data) else {
            return nil
        }
        return goal
    }
    
    func clearCache(userId: String) async throws {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        let userKeys = allKeys.filter { $0.contains(getCacheKey(userId: userId)) || $0.contains(getActiveGoalCacheKey(userId: userId)) }
        
        for key in userKeys {
            userDefaults.removeObject(forKey: key)
        }
    }
}
