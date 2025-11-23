//
//  IngredientAmountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI
import CustomRouting

struct IngredientAmountViewDelegate {
    var ingredient: IngredientTemplateModel
    let onPick: (MealItemModel) -> Void
}

struct IngredientAmountView: View {

    @State var viewModel: IngredientAmountViewModel

    var delegate: IngredientAmountViewDelegate

    var body: some View {
        Form {
            Section("Amount") {
                HStack {
                    TextField("Amount", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                    Text(viewModel.unitLabel(ingredient: delegate.ingredient))
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Estimated Macros") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(viewModel.calories(ingredient: delegate.ingredient).map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(viewModel.protein(ingredient: delegate.ingredient).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(viewModel.carbs(ingredient: delegate.ingredient).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(viewModel.fat(ingredient: delegate.ingredient).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(delegate.ingredient.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { viewModel.add(ingredient: delegate.ingredient, onConfirm: delegate.onPick) }
                    .disabled((Double(viewModel.amountText) ?? 0) <= 0)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.ingredientAmountView(
            router: router, 
            delegate: IngredientAmountViewDelegate(
                ingredient: IngredientTemplateModel.mock,
                onPick: {ingredient in
                    print(
                        ingredient.displayName
                    )
                }
            )
        )
    }
}
