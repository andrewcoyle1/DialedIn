//
//  IngredientAmountPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

@Observable
@MainActor
class IngredientAmountPresenter {
    private let interactor: IngredientAmountInteractor
    private let router: IngredientAmountRouter

    var amountText: String = "100"

    func unitLabel(ingredient: FoodModel) -> String {
        switch ingredient.measurementMethod {
        case .weight: return "g"
        case .volume: return "ml"
        }
    }

    var amountValue: Double { Double(amountText) ?? 0 }
    var scale: Double { max(amountValue, 0) / 100.0 }
    func calories(ingredient: FoodModel) -> Double? { ingredient.calories.map { $0 * scale } }
    func protein(ingredient: FoodModel) -> Double? { ingredient.protein.map { $0 * scale } }
    func carbs(ingredient: FoodModel) -> Double? { ingredient.carbs.map { $0 * scale } }
    func fat(ingredient: FoodModel) -> Double? { ingredient.fatTotal.map { $0 * scale } }

    init(
        interactor: IngredientAmountInteractor,
        router: IngredientAmountRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func add(ingredient: FoodModel, onConfirm: @escaping (MealItemModel) -> Void) {
        let resolvedGrams = ingredient.measurementMethod == .weight ? amountValue : nil
        let resolvedMl = ingredient.measurementMethod == .volume ? amountValue : nil
        var scaledNutrients: NutrientMap = NutrientMap()
        for (key, value) in ingredient.nutrients {
            scaledNutrients[key] = value * scale
        }
        let item = MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: ingredient.ingredientId,
            displayName: ingredient.name,
            amount: amountValue,
            unit: unitLabel(ingredient: ingredient),
            resolvedGrams: resolvedGrams,
            resolvedMilliliters: resolvedMl,
            nutrients: scaledNutrients
        )
        onConfirm(item)
    }

    func dismissScreen() {
        router.dismissScreen()
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif
}
