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

@Observable
@MainActor
class RecipeAmountViewModel {
    private let interactor: RecipeAmountInteractor
    let recipe: RecipeTemplateModel
    let onConfirm: (MealItemModel) -> Void

    var servingsText: String = "1"

    var baseCalories: Double? {
        aggregate { $0.calories }
    }

    var baseProtein: Double? {
        aggregate { $0.protein }
    }

    var baseCarbs: Double? {
        aggregate { $0.carbs }
    }

    var baseFat: Double? {
        aggregate { $0.fatTotal }
    }

    var servings: Double { max(Double(servingsText) ?? 0, 0) }

    init(
        interactor: RecipeAmountInteractor,
        recipe: RecipeTemplateModel,
        onConfirm: @escaping (MealItemModel) -> Void
    ) {
        self.interactor = interactor
        self.recipe = recipe
        self.onConfirm = onConfirm
    }

    func aggregate(_ keyPath: (IngredientTemplateModel) -> Double?) -> Double? {
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

    func add() {
        let calories = baseCalories.map { $0 * servings }
        let protein = baseProtein.map { $0 * servings }
        let carbs = baseCarbs.map { $0 * servings }
        let fat = baseFat.map { $0 * servings }
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
}
