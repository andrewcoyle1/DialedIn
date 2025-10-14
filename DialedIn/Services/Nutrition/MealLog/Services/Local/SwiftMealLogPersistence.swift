//
//  SwiftMealLogPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import Foundation
import SwiftUI

@MainActor
struct SwiftMealLogPersistence: LocalMealLogPersistence {
    private let mealsKey = "local_meal_logs_v1"
    private let queue = DispatchQueue(label: "SwiftMealLogPersistence.queue")

    private func loadAll() -> [String: [MealLogModel]] {
        if let data = UserDefaults.standard.data(forKey: mealsKey) {
            if let result = try? JSONDecoder().decode([String: [MealLogModel]].self, from: data) {
                return result
            }
        }
        return [:]
    }

    private func saveAll(_ dict: [String: [MealLogModel]]) {
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: mealsKey)
        }
    }

    func addLocalMeal(_ meal: MealLogModel) throws {
        var store = loadAll()
        var dayMeals = store[meal.dayKey] ?? []
        dayMeals.append(meal)
        store[meal.dayKey] = dayMeals
        saveAll(store)
    }

    func updateLocalMeal(_ meal: MealLogModel) throws {
        var store = loadAll()
        var dayMeals = store[meal.dayKey] ?? []
        if let idx = dayMeals.firstIndex(where: { $0.mealId == meal.mealId }) {
            dayMeals[idx] = meal
            store[meal.dayKey] = dayMeals
            saveAll(store)
        }
    }

    func deleteLocalMeal(id: String, dayKey: String) throws {
        var store = loadAll()
        var dayMeals = store[dayKey] ?? []
        dayMeals.removeAll { $0.mealId == id }
        store[dayKey] = dayMeals
        saveAll(store)
    }

    func getLocalMeal(id: String) throws -> MealLogModel {
        let store = loadAll()
        for (_, meals) in store {
            if let found = meals.first(where: { $0.mealId == id }) {
                return found
            }
        }
        throw NSError(domain: "SwiftMealLogPersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "Meal not found"])
    }

    func getLocalMeals(dayKey: String) throws -> [MealLogModel] {
        let store = loadAll()
        return store[dayKey] ?? []
    }

    func getLocalMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] {
        let store = loadAll()
        let keys = store.keys.sorted()
        let filteredKeys = keys.filter { $0 >= startDayKey && $0 <= endDayKey }
        return filteredKeys.flatMap { store[$0] ?? [] }
    }

    func getLocalDailyTotals(dayKey: String) throws -> DailyMacroTarget {
        let meals = try getLocalMeals(dayKey: dayKey)
        let totals = meals.reduce((cal: 0.0, protein: 0.0, carbs: 0.0, fats: 0.0)) { acc, meal in
            (acc.cal + meal.totalCalories,
             acc.protein + meal.totalProteinGrams,
             acc.carbs + meal.totalCarbGrams,
             acc.fats + meal.totalFatGrams)
        }
        return DailyMacroTarget(
            calories: totals.cal,
            proteinGrams: totals.protein,
            carbGrams: totals.carbs,
            fatGrams: totals.fats
        )
    }
}
