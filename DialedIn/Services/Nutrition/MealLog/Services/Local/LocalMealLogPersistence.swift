//
//  LocalMealLogPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import Foundation

@MainActor
protocol LocalMealLogPersistence {
    func addLocalMeal(_ meal: MealLogModel) throws
    func updateLocalMeal(_ meal: MealLogModel) throws
    func deleteLocalMeal(id: String, dayKey: String) throws
    func getLocalMeal(id: String) throws -> MealLogModel
    func getLocalMeals(dayKey: String) throws -> [MealLogModel]
    func getLocalMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel]
    func getLocalDailyTotals(dayKey: String) throws -> DailyMacroTarget
}
