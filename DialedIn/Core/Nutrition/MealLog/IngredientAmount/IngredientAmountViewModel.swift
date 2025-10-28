//
//  IngredientAmountViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

protocol IngredientAmountInteractor {

}

extension CoreInteractor: IngredientAmountInteractor { }

@Observable
@MainActor
class IngredientAmountViewModel {
    private let interactor: IngredientAmountInteractor
    let ingredient: IngredientTemplateModel
    private let onConfirm: (MealItemModel) -> Void

    var amountText: String = "100"

    var unitLabel: String {
        switch ingredient.measurementMethod {
        case .weight: return "g"
        case .volume: return "ml"
        }
    }

    var amountValue: Double { Double(amountText) ?? 0 }
    var scale: Double { max(amountValue, 0) / 100.0 }
    var calories: Double? { ingredient.calories.map { $0 * scale } }
    var protein: Double? { ingredient.protein.map { $0 * scale } }
    var carbs: Double? { ingredient.carbs.map { $0 * scale } }
    var fat: Double? { ingredient.fatTotal.map { $0 * scale } }

    init(
        interactor: IngredientAmountInteractor,
        ingredient: IngredientTemplateModel,
        onConfirm: @escaping (MealItemModel) -> Void
    ) {
        self.interactor = interactor
        self.ingredient = ingredient
        self.onConfirm = onConfirm
    }

    func add() {
        let resolvedGrams = ingredient.measurementMethod == .weight ? amountValue : nil
        let resolvedMl = ingredient.measurementMethod == .volume ? amountValue : nil
        let item = MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: ingredient.ingredientId,
            displayName: ingredient.name,
            amount: amountValue,
            unit: unitLabel,
            resolvedGrams: resolvedGrams,
            resolvedMilliliters: resolvedMl,
            calories: calories,
            proteinGrams: protein,
            carbGrams: carbs,
            fatGrams: fat
        )
        onConfirm(item)
    }
}
