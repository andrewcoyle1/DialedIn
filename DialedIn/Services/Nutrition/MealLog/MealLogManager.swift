//
//  MealLogManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

@Observable
class MealLogManager: LocalMealLogPersistence, RemoteMealLogService {
    
    private let local: LocalMealLogPersistence
    private let remote: RemoteMealLogService
    
    // UI state for draft/edit flows
    var draftMeal: MealLogModel?
    
    init(services: MealLogServices) {
        self.remote = services.remote
        self.local = services.local
    }
    
    // MARK: - High-level API
    func addMeal(_ meal: MealLogModel) async throws {
        try local.addLocalMeal(meal)
        try await remote.createMeal(meal)
    }
    
    func updateMealAndSync(_ meal: MealLogModel) async throws {
        try local.updateLocalMeal(meal)
        try await remote.updateMeal(meal)
    }
    
    func deleteMealAndSync(id: String, dayKey: String, authorId: String) async throws {
        try local.deleteLocalMeal(id: id, dayKey: dayKey)
        try await remote.deleteMeal(id: id, dayKey: dayKey, authorId: authorId)
    }
    
    func getMeals(for dayKey: String) throws -> [MealLogModel] {
        try local.getLocalMeals(dayKey: dayKey)
    }
    
    func getMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] {
        try local.getLocalMeals(startDayKey: startDayKey, endDayKey: endDayKey)
    }
    
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget {
        try local.getLocalDailyTotals(dayKey: dayKey)
    }
    
    // MARK: - LocalMealLogPersistence
    func addLocalMeal(_ meal: MealLogModel) throws { try local.addLocalMeal(meal) }
    func updateLocalMeal(_ meal: MealLogModel) throws { try local.updateLocalMeal(meal) }
    func deleteLocalMeal(id: String, dayKey: String) throws { try local.deleteLocalMeal(id: id, dayKey: dayKey) }
    func getLocalMeal(id: String) throws -> MealLogModel { try local.getLocalMeal(id: id) }
    func getLocalMeals(dayKey: String) throws -> [MealLogModel] { try local.getLocalMeals(dayKey: dayKey) }
    func getLocalMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] { try local.getLocalMeals(startDayKey: startDayKey, endDayKey: endDayKey) }
    func getLocalDailyTotals(dayKey: String) throws -> DailyMacroTarget { try local.getLocalDailyTotals(dayKey: dayKey) }
    
    // MARK: - RemoteMealLogService
    func createMeal(_ meal: MealLogModel) async throws { try await remote.createMeal(meal) }
    func updateMeal(_ meal: MealLogModel) async throws { try await remote.updateMeal(meal) }
    func deleteMeal(id: String, dayKey: String, authorId: String) async throws { try await remote.deleteMeal(id: id, dayKey: dayKey, authorId: authorId) }
    func getMeals(dayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] { try await remote.getMeals(dayKey: dayKey, authorId: authorId, limitTo: limitTo) }
    func getMeals(startDayKey: String, endDayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] { try await remote.getMeals(startDayKey: startDayKey, endDayKey: endDayKey, authorId: authorId, limitTo: limitTo) }
}
