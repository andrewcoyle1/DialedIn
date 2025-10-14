//
//  RemoteMealLogService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

protocol RemoteMealLogService {
    func createMeal(_ meal: MealLogModel) async throws
    func updateMeal(_ meal: MealLogModel) async throws
    func deleteMeal(id: String, dayKey: String, authorId: String) async throws
    func getMeals(dayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel]
    func getMeals(startDayKey: String, endDayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel]
}
