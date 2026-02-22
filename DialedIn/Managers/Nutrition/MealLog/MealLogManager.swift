//
//  MealLogManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

@Observable
@MainActor
class MealLogManager {
    
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

extension CoreInteractor {
    // MARK: MealLogManager
    
    var draftMeal: MealLogModel? {
        mealLogManager.draftMeal
    }
    
    func addMeal(_ meal: MealLogModel) async throws {
        try await mealLogManager.addMeal(meal)
    }
    
    func updateMealAndSync(_ meal: MealLogModel) async throws {
        try await mealLogManager.updateMealAndSync(meal)
    }
    
    func deleteMealAndSync(id: String, dayKey: String, authorId: String) async throws {
        try await mealLogManager.deleteMealAndSync(id: id, dayKey: dayKey, authorId: authorId)
    }
    
    func getMeals(for dayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getMeals(for: dayKey)
    }
    
    func getMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getLocalMeals(startDayKey: startDayKey, endDayKey: endDayKey)
    }
    
    func getDailyTotals(dayKey: String) throws -> DailyMacroTarget {
        try mealLogManager.getLocalDailyTotals(dayKey: dayKey)
    }
    
    func getDailyTotals(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, totals: DailyMacroTarget)] {
        guard let startDate = Date(dayKey: startDayKey), let endDate = Date(dayKey: endDayKey), startDate <= endDate else {
            return []
        }
        let keys = Date.dayKeys(from: startDate, to: endDate)
        return keys.map { key in
            (dayKey: key, totals: (try? mealLogManager.getLocalDailyTotals(dayKey: key)) ?? DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0))
        }
    }
    
    // LocalMealLogPersistence
    
    func addLocalMeal(_ meal: MealLogModel) throws {
        try mealLogManager.addLocalMeal(meal)
    }
    
    func updateLocalMeal(_ meal: MealLogModel) throws {
        try mealLogManager.updateLocalMeal(meal)
    }
    
    func deleteLocalMeal(id: String, dayKey: String) throws {
        try mealLogManager.deleteLocalMeal(id: id, dayKey: dayKey)
    }
    
    func getLocalMeal(id: String) throws -> MealLogModel {
        try mealLogManager.getLocalMeal(id: id)
    }
    
    func getLocalMeals(dayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getLocalMeals(dayKey: dayKey)
    }
    
    func getLocalMeals(startDayKey: String, endDayKey: String) throws -> [MealLogModel] {
        try mealLogManager.getLocalMeals(startDayKey: startDayKey, endDayKey: endDayKey)
    }
    
    func getLocalDailyTotals(dayKey: String) throws -> DailyMacroTarget {
        try mealLogManager.getLocalDailyTotals(dayKey: dayKey)
    }
    
    func getDailyNutritionBreakdown(dayKey: String) throws -> DailyNutritionBreakdown {
        let meals = try mealLogManager.getMeals(for: dayKey)
        var breakdown = DailyNutritionBreakdown()
        for meal in meals {
            for item in meal.items {
                if item.sourceType == .ingredient {
                    if let ingredient = try? ingredientTemplateManager.getLocalIngredientTemplate(id: item.sourceId) {
                        let scale = ((item.resolvedGrams ?? item.resolvedMilliliters) ?? 0) / 100.0
                        addIngredientToBreakdown(ingredient, scale: scale, into: &breakdown)
                    }
                } else if item.sourceType == .recipe {
                    if let recipe = try? recipeTemplateManager.getLocalRecipeTemplate(id: item.sourceId) {
                        let recipeTotals = aggregateRecipeNutrients(recipe: recipe)
                        let scale = item.amount
                        addRecipeTotalsToBreakdown(recipeTotals, scale: scale, into: &breakdown)
                    }
                }
            }
        }
        if let fiber = breakdown.fiberGrams, let carbs = try? mealLogManager.getLocalDailyTotals(dayKey: dayKey).carbGrams {
            breakdown.netCarbsGrams = max(0, carbs - fiber)
        }
        return breakdown
    }
    
    func getDailyNutritionBreakdown(startDayKey: String, endDayKey: String) throws -> [(dayKey: String, breakdown: DailyNutritionBreakdown)] {
        guard let startDate = Date(dayKey: startDayKey), let endDate = Date(dayKey: endDayKey), startDate <= endDate else {
            return []
        }
        let keys = Date.dayKeys(from: startDate, to: endDate)
        return keys.map { key in
            (dayKey: key, breakdown: (try? getDailyNutritionBreakdown(dayKey: key)) ?? DailyNutritionBreakdown.empty)
        }
    }
    
    private func addIngredientToBreakdown(_ ingredient: IngredientTemplateModel, scale: Double, into breakdown: inout DailyNutritionBreakdown) {
        func add(_ value: Double?, to keyPath: inout Double?) {
            guard let value, value > 0 else { return }
            keyPath = (keyPath ?? 0) + value * scale
        }
        add(ingredient.fiber, to: &breakdown.fiberGrams)
        add(ingredient.sugar, to: &breakdown.sugarGrams)
        add(ingredient.fatSaturated, to: &breakdown.fatSaturatedGrams)
        add(ingredient.fatMonounsaturated, to: &breakdown.fatMonounsaturatedGrams)
        add(ingredient.fatPolyunsaturated, to: &breakdown.fatPolyunsaturatedGrams)
        add(ingredient.sodiumMg, to: &breakdown.sodiumMg)
        add(ingredient.potassiumMg, to: &breakdown.potassiumMg)
        add(ingredient.calciumMg, to: &breakdown.calciumMg)
        add(ingredient.ironMg, to: &breakdown.ironMg)
        add(ingredient.magnesiumMg, to: &breakdown.magnesiumMg)
        add(ingredient.zincMg, to: &breakdown.zincMg)
        add(ingredient.copperMg, to: &breakdown.copperMg)
        add(ingredient.manganeseMg, to: &breakdown.manganeseMg)
        add(ingredient.phosphorusMg, to: &breakdown.phosphorusMg)
        add(ingredient.seleniumMcg, to: &breakdown.seleniumMcg)
        add(ingredient.vitaminAMcg, to: &breakdown.vitaminAMcg)
        add(ingredient.vitaminB6Mg, to: &breakdown.vitaminB6Mg)
        add(ingredient.vitaminB12Mcg, to: &breakdown.vitaminB12Mcg)
        add(ingredient.vitaminCMg, to: &breakdown.vitaminCMg)
        add(ingredient.vitaminDMcg, to: &breakdown.vitaminDMcg)
        add(ingredient.vitaminEMg, to: &breakdown.vitaminEMg)
        add(ingredient.vitaminKMcg, to: &breakdown.vitaminKMcg)
        add(ingredient.thiaminMg, to: &breakdown.thiaminMg)
        add(ingredient.riboflavinMg, to: &breakdown.riboflavinMg)
        add(ingredient.niacinMg, to: &breakdown.niacinMg)
        add(ingredient.pantothenicAcidMg, to: &breakdown.pantothenicAcidMg)
        add(ingredient.folateMcg, to: &breakdown.folateMcg)
        add(ingredient.caffeineMg, to: &breakdown.caffeineMg)
        add(ingredient.cholesterolMg, to: &breakdown.cholesterolMg)
    }
    
    private struct RecipeNutrientTotals {
        var fiberGrams: Double = 0
        var sugarGrams: Double = 0
        var fatSaturatedGrams: Double = 0
        var fatMonounsaturatedGrams: Double = 0
        var fatPolyunsaturatedGrams: Double = 0
        var sodiumMg: Double = 0
        var potassiumMg: Double = 0
        var calciumMg: Double = 0
        var ironMg: Double = 0
        var magnesiumMg: Double = 0
        var zincMg: Double = 0
        var copperMg: Double = 0
        var manganeseMg: Double = 0
        var phosphorusMg: Double = 0
        var seleniumMcg: Double = 0
        var vitaminAMcg: Double = 0
        var vitaminB6Mg: Double = 0
        var vitaminB12Mcg: Double = 0
        var vitaminCMg: Double = 0
        var vitaminDMcg: Double = 0
        var vitaminEMg: Double = 0
        var vitaminKMcg: Double = 0
        var thiaminMg: Double = 0
        var riboflavinMg: Double = 0
        var niacinMg: Double = 0
        var pantothenicAcidMg: Double = 0
        var folateMcg: Double = 0
        var caffeineMg: Double = 0
        var cholesterolMg: Double = 0
    }
    
    private func aggregateRecipeNutrients(recipe: RecipeTemplateModel) -> RecipeNutrientTotals {
        var totals = RecipeNutrientTotals()
        for ringredient in recipe.ingredients {
            let grams: Double
            switch ringredient.unit {
            case .grams: grams = ringredient.amount
            case .milliliters: grams = ringredient.amount
            case .units: grams = ringredient.amount * 100
            }
            let scale = grams / 100.0
            addScaledIngredientNutrients(ringredient.ingredient, scale: scale, into: &totals)
        }
        return totals
    }

    private func addScaledIngredientNutrients(_ ingredient: IngredientTemplateModel, scale: Double, into totals: inout RecipeNutrientTotals) {
        addScaled(ingredient.fiber, to: &totals.fiberGrams, scale: scale)
        addScaled(ingredient.sugar, to: &totals.sugarGrams, scale: scale)
        addScaled(ingredient.fatSaturated, to: &totals.fatSaturatedGrams, scale: scale)
        addScaled(ingredient.fatMonounsaturated, to: &totals.fatMonounsaturatedGrams, scale: scale)
        addScaled(ingredient.fatPolyunsaturated, to: &totals.fatPolyunsaturatedGrams, scale: scale)
        addScaled(ingredient.sodiumMg, to: &totals.sodiumMg, scale: scale)
        addScaled(ingredient.potassiumMg, to: &totals.potassiumMg, scale: scale)
        addScaled(ingredient.calciumMg, to: &totals.calciumMg, scale: scale)
        addScaled(ingredient.ironMg, to: &totals.ironMg, scale: scale)
        addScaled(ingredient.magnesiumMg, to: &totals.magnesiumMg, scale: scale)
        addScaled(ingredient.zincMg, to: &totals.zincMg, scale: scale)
        addScaled(ingredient.copperMg, to: &totals.copperMg, scale: scale)
        addScaled(ingredient.manganeseMg, to: &totals.manganeseMg, scale: scale)
        addScaled(ingredient.phosphorusMg, to: &totals.phosphorusMg, scale: scale)
        addScaled(ingredient.seleniumMcg, to: &totals.seleniumMcg, scale: scale)
        addScaled(ingredient.vitaminAMcg, to: &totals.vitaminAMcg, scale: scale)
        addScaled(ingredient.vitaminB6Mg, to: &totals.vitaminB6Mg, scale: scale)
        addScaled(ingredient.vitaminB12Mcg, to: &totals.vitaminB12Mcg, scale: scale)
        addScaled(ingredient.vitaminCMg, to: &totals.vitaminCMg, scale: scale)
        addScaled(ingredient.vitaminDMcg, to: &totals.vitaminDMcg, scale: scale)
        addScaled(ingredient.vitaminEMg, to: &totals.vitaminEMg, scale: scale)
        addScaled(ingredient.vitaminKMcg, to: &totals.vitaminKMcg, scale: scale)
        addScaled(ingredient.thiaminMg, to: &totals.thiaminMg, scale: scale)
        addScaled(ingredient.riboflavinMg, to: &totals.riboflavinMg, scale: scale)
        addScaled(ingredient.niacinMg, to: &totals.niacinMg, scale: scale)
        addScaled(ingredient.pantothenicAcidMg, to: &totals.pantothenicAcidMg, scale: scale)
        addScaled(ingredient.folateMcg, to: &totals.folateMcg, scale: scale)
        addScaled(ingredient.caffeineMg, to: &totals.caffeineMg, scale: scale)
        addScaled(ingredient.cholesterolMg, to: &totals.cholesterolMg, scale: scale)
    }

    private func addScaled(_ value: Double?, to total: inout Double, scale: Double) {
        guard let value else { return }
        total += value * scale
    }
    
    private func addRecipeTotalsToBreakdown(_ totals: RecipeNutrientTotals, scale: Double, into breakdown: inout DailyNutritionBreakdown) {
        func add(_ value: Double, to keyPath: inout Double?) {
            guard value > 0 else { return }
            keyPath = (keyPath ?? 0) + value * scale
        }
        add(totals.fiberGrams, to: &breakdown.fiberGrams)
        add(totals.sugarGrams, to: &breakdown.sugarGrams)
        add(totals.fatSaturatedGrams, to: &breakdown.fatSaturatedGrams)
        add(totals.fatMonounsaturatedGrams, to: &breakdown.fatMonounsaturatedGrams)
        add(totals.fatPolyunsaturatedGrams, to: &breakdown.fatPolyunsaturatedGrams)
        add(totals.sodiumMg, to: &breakdown.sodiumMg)
        add(totals.potassiumMg, to: &breakdown.potassiumMg)
        add(totals.calciumMg, to: &breakdown.calciumMg)
        add(totals.ironMg, to: &breakdown.ironMg)
        add(totals.magnesiumMg, to: &breakdown.magnesiumMg)
        add(totals.zincMg, to: &breakdown.zincMg)
        add(totals.copperMg, to: &breakdown.copperMg)
        add(totals.manganeseMg, to: &breakdown.manganeseMg)
        add(totals.phosphorusMg, to: &breakdown.phosphorusMg)
        add(totals.seleniumMcg, to: &breakdown.seleniumMcg)
        add(totals.vitaminAMcg, to: &breakdown.vitaminAMcg)
        add(totals.vitaminB6Mg, to: &breakdown.vitaminB6Mg)
        add(totals.vitaminB12Mcg, to: &breakdown.vitaminB12Mcg)
        add(totals.vitaminCMg, to: &breakdown.vitaminCMg)
        add(totals.vitaminDMcg, to: &breakdown.vitaminDMcg)
        add(totals.vitaminEMg, to: &breakdown.vitaminEMg)
        add(totals.vitaminKMcg, to: &breakdown.vitaminKMcg)
        add(totals.thiaminMg, to: &breakdown.thiaminMg)
        add(totals.riboflavinMg, to: &breakdown.riboflavinMg)
        add(totals.niacinMg, to: &breakdown.niacinMg)
        add(totals.pantothenicAcidMg, to: &breakdown.pantothenicAcidMg)
        add(totals.folateMcg, to: &breakdown.folateMcg)
        add(totals.caffeineMg, to: &breakdown.caffeineMg)
        add(totals.cholesterolMg, to: &breakdown.cholesterolMg)
    }
    
    // RemoteMealLogService
    
    func createMeal(_ meal: MealLogModel) async throws {
        try await mealLogManager.createMeal(meal)
    }
    
    func updateMeal(_ meal: MealLogModel) async throws {
        try await mealLogManager.updateMeal(meal)
    }
    
    func deleteMeal(id: String, dayKey: String, authorId: String) async throws {
        try await mealLogManager.deleteMeal(id: id, dayKey: dayKey, authorId: authorId)
    }
    
    func getMeals(dayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        try await mealLogManager.getMeals(dayKey: dayKey, authorId: authorId, limitTo: limitTo)
    }
    
    func getMeals(startDayKey: String, endDayKey: String, authorId: String, limitTo: Int) async throws -> [MealLogModel] {
        try await mealLogManager.getMeals(startDayKey: startDayKey, endDayKey: endDayKey, authorId: authorId, limitTo: limitTo)
    }

}
