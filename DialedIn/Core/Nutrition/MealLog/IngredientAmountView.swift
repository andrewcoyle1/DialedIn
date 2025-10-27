//
//  IngredientAmountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

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

struct IngredientAmountView: View {
    @State var viewModel: IngredientAmountViewModel

    var body: some View {
        Form {
            Section("Amount") {
                HStack {
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                    Text(viewModel.unitLabel)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Estimated Macros") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(viewModel.calories.map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(viewModel.protein.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(viewModel.carbs.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(viewModel.fat.map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(viewModel.ingredient.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { viewModel.add() }
                    .disabled((Double(viewModel.amountText) ?? 0) <= 0)
            }
        }
    }
}

#Preview {
    IngredientAmountView(
        viewModel: IngredientAmountViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            ingredient: IngredientTemplateModel.mock,
            onConfirm: {ingredient in
                print(
                    ingredient.displayName
                )
            }
        )
    )
}
