//
//  RecipeAmountViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

protocol RecipeAmountInteractor {

}

extension CoreInteractor: RecipeAmountInteractor { }

@MainActor
protocol RecipeAmountRouter {
    func showDevSettingsView()
}

extension CoreRouter: RecipeAmountRouter { }

@Observable
@MainActor
class RecipeAmountViewModel {
    private let interactor: RecipeAmountInteractor
    private let router: RecipeAmountRouter

    var servingsText: String = "1"

    var servings: Double { max(Double(servingsText) ?? 0, 0) }

    init(
        interactor: RecipeAmountInteractor,
        router: RecipeAmountRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    private func aggregate(_ keyPath: (IngredientTemplateModel) -> Double?, recipe: RecipeTemplateModel) -> Double? {
        var total: Double = 0
        var hasValue = false
        for recipeIngredient in recipe.ingredients {
            guard let per100 = keyPath(recipeIngredient.ingredient) else { continue }
            hasValue = true
            let grams: Double
            switch recipeIngredient.unit {
            case .grams:
                grams = recipeIngredient.amount
            case .milliliters:
                grams = recipeIngredient.amount // approximation
            case .units:
                grams = recipeIngredient.amount * 100 // rough fallback
            }
            total += per100 * (grams / 100.0)
        }
        return hasValue ? total : nil
    }

    func baseCalories(recipe: RecipeTemplateModel) -> Double? {
        aggregate({ $0.calories }, recipe: recipe)
    }

    func baseProtein(recipe: RecipeTemplateModel) -> Double? {
        aggregate({ $0.protein }, recipe: recipe)
    }

    func baseCarbs(recipe: RecipeTemplateModel) -> Double? {
        aggregate({ $0.carbs }, recipe: recipe)
    }

    func baseFat(recipe: RecipeTemplateModel) -> Double? {
        aggregate({ $0.fatTotal }, recipe: recipe)
    }

    func add(recipe: RecipeTemplateModel, onConfirm: @escaping (MealItemModel) -> Void) {
        let calories = baseCalories(recipe: recipe).map { $0 * servings }
        let protein = baseProtein(recipe: recipe).map { $0 * servings }
        let carbs = baseCarbs(recipe: recipe).map { $0 * servings }
        let fat = baseFat(recipe: recipe).map { $0 * servings }
        let item = MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .recipe,
            sourceId: recipe.recipeId,
            displayName: recipe.name,
            amount: servings,
            unit: "serving",
            resolvedGrams: nil,
            resolvedMilliliters: nil,
            calories: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat
        )
        onConfirm(item)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
