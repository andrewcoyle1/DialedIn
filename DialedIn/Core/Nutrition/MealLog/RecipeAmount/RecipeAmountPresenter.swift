//
//  RecipeAmountPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

@Observable
@MainActor
class RecipeAmountPresenter {
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

    /// Grams of an ingredient as used in the recipe. Millilitres are taken one-for-one with grams,
    /// and a counted unit as 100g, which is the same assumption the recipe builder makes.
    private func grams(of recipeIngredient: RecipeIngredientModel) -> Double {
        switch recipeIngredient.unit {
        case .grams:
            return recipeIngredient.amount
        case .milliliters:
            return recipeIngredient.amount // approximation
        case .units:
            return recipeIngredient.amount * 100 // rough fallback
        }
    }

    /// How much of the recipe one serving is. Floors at one so a recipe saved claiming no servings
    /// reads as a single serving rather than dividing by zero.
    private func servingDivisor(_ recipe: RecipeTemplateModel) -> Double {
        max(recipe.servingQuantity, 1)
    }

    /// One serving's worth of a nutrient — the recipe's total divided across its servings.
    private func aggregate(_ keyPath: (FoodModel) -> Double?, recipe: RecipeTemplateModel) -> Double? {
        var total: Double = 0
        var hasValue = false
        for recipeIngredient in recipe.ingredients {
            guard let per100 = keyPath(recipeIngredient.ingredient) else { continue }
            hasValue = true
            total += per100 * (grams(of: recipeIngredient) / 100.0)
        }
        return hasValue ? total / servingDivisor(recipe) : nil
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
        var recipeNutrients = NutrientMap()
        for recipeIngredient in recipe.ingredients {
            let scale = grams(of: recipeIngredient) / 100.0
            for (key, value) in recipeIngredient.ingredient.nutrients {
                recipeNutrients[key, default: 0] += value * scale
            }
        }
        // Per serving first, then by how many servings were eaten. Scaling the whole recipe by the
        // servings instead logged the entire pot for every serving — a four-serving dish went in
        // at four times what was eaten.
        let perServing = recipeNutrients.mapValues { $0 / servingDivisor(recipe) }
        let scaledNutrients = perServing.mapValues { $0 * servings }
        let item = MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .recipe,
            sourceId: recipe.recipeId,
            displayName: recipe.name,
            amount: servings,
            unit: "serving",
            resolvedGrams: nil,
            resolvedMilliliters: nil,
            nutrients: scaledNutrients
        )
        onConfirm(item)
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif
}
