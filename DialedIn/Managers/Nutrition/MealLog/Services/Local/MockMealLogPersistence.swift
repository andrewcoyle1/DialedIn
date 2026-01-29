//
//  MockMealLogPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import Foundation

struct MockMealLogPersistence: LocalMealLogPersistence {
    private var store: [String: [MealLogModel]]
    private let showError: Bool
    
    init(mealsByDay: [String: [MealLogModel]] = [:], showError: Bool = false) {
        self.store = mealsByDay
        self.showError = showError
    }
    
    func addLocalMeal(_ meal: MealLogModel) throws {
        if showError { throw NSError(domain: "MockMealLogPersistence", code: -1) }
        var copy = store
        var dayMeals = copy[meal.dayKey] ?? []
        dayMeals.append(meal)
        copy[meal.dayKey] = dayMeals
    }
    
    func updateLocalMeal(_ meal: MealLogModel) throws {
        if showError { throw NSError(domain: "MockMealLogPersistence", code: -1) }
    }
    
    func deleteLocalMeal(id: String, dayKey: String) throws {
        if showError { throw NSError(domain: "MockMealLogPersistence", code: -1) }
    }
    
    func getLocalMeal(id: String) throws -> MealLogModel {
        if showError { throw NSError(domain: "MockMealLogPersistence", code: -1) }
        for (_, meals) in store {
            if let found = meals.first(where: { $0.mealId == id }) { return found }
        }
        throw NSError(domain: "MockMealLogPersistence", code: 404)
    }
    
    func getLocalMeals(dayKey: String) throws -> [MealLogModel] {
        if showError { throw NSError(domain: "MockMealLogPersistence", code: -1) }
        return store[dayKey] ?? []
    }
    
    func getLocalMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] {
        if showError { throw NSError(domain: "MockMealLogPersistence", code: -1) }
        let keys = store.keys.sorted().filter { $0 >= startDayKey && $0 <= endDayKey }
        return keys.flatMap { store[$0] ?? [] }
    }
    
    func getLocalDailyTotals(dayKey: String) throws -> DailyMacroTarget {
        let meals = try getLocalMeals(dayKey: dayKey)
        let totals = meals.reduce((0.0, 0.0, 0.0, 0.0)) { acc, meal in
            (acc.0 + meal.totalCalories,
             acc.1 + meal.totalProteinGrams,
             acc.2 + meal.totalCarbGrams,
             acc.3 + meal.totalFatGrams)
        }
        return DailyMacroTarget(calories: totals.0, proteinGrams: totals.1, carbGrams: totals.2, fatGrams: totals.3)
    }
}
