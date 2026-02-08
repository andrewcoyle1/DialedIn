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
    
    var mealsLastModified: Date = Date()

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
    
    func deleteAllMealLogsForAuthor(authorId: String) async throws {
        try await remote.deleteAllMealLogsForAuthor(authorId: authorId)
        mealsLastModified = Date()

    }
    
    // MARK: - Sync Operations
    
    /// Syncs meal logs from remote Firebase to local storage.
    /// Fetches meals for the last 90 days and upserts into local store.
    func syncMealsFromRemote(authorId: String, limitTo: Int = 1000) async throws {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -90, to: endDate) else { return }
        let startDayKey = startDate.dayKey
        let endDayKey = endDate.dayKey
        let remoteMeals = try await remote.getMeals(
            startDayKey: startDayKey,
            endDayKey: endDayKey,
            authorId: authorId,
            limitTo: limitTo
        )
        for meal in remoteMeals {
            do {
                _ = try local.getLocalMeal(id: meal.mealId)
                try local.updateLocalMeal(meal)
            } catch {
                try local.addLocalMeal(meal)
            }
        }
        mealsLastModified = Date()
    }

    /// Uploads local meal logs to Firebase so they appear on other devices.
    /// Use when meals may exist only locally (e.g. added offline, prior sync failure).
    func uploadLocalMealsToRemote(authorId: String) async throws {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -90, to: endDate) else { return }
        let startDayKey = startDate.dayKey
        let endDayKey = endDate.dayKey
        let localMeals = try local.getLocalMeals(startDayKey: startDayKey, endDayKey: endDayKey)
        for meal in localMeals where meal.authorId == authorId {
            try? await remote.updateMeal(meal)
        }
        mealsLastModified = Date()
    }
}
