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

    func unitLabel(ingredient: IngredientTemplateModel) -> String {
        switch ingredient.measurementMethod {
        case .weight: return "g"
        case .volume: return "ml"
        }
    }

    var amountValue: Double { Double(amountText) ?? 0 }
    var scale: Double { max(amountValue, 0) / 100.0 }
    func calories(ingredient: IngredientTemplateModel) -> Double? { ingredient.calories.map { $0 * scale } }
    func protein(ingredient: IngredientTemplateModel) -> Double? { ingredient.protein.map { $0 * scale } }
    func carbs(ingredient: IngredientTemplateModel) -> Double? { ingredient.carbs.map { $0 * scale } }
    func fat(ingredient: IngredientTemplateModel) -> Double? { ingredient.fatTotal.map { $0 * scale } }

    init(
        interactor: IngredientAmountInteractor,
        router: IngredientAmountRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func add(ingredient: IngredientTemplateModel, onConfirm: @escaping (MealItemModel) -> Void) {
        let resolvedGrams = ingredient.measurementMethod == .weight ? amountValue : nil
        let resolvedMl = ingredient.measurementMethod == .volume ? amountValue : nil
        let item = MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: ingredient.ingredientId,
            displayName: ingredient.name,
            amount: amountValue,
            unit: unitLabel(ingredient: ingredient),
            resolvedGrams: resolvedGrams,
            resolvedMilliliters: resolvedMl,
            calories: calories(ingredient: ingredient),
            proteinGrams: protein(ingredient: ingredient),
            carbGrams: carbs(ingredient: ingredient),
            fatGrams: fat(ingredient: ingredient)
        )
        onConfirm(item)
    }

    func dismissScreen() {
        router.dismissScreen()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
