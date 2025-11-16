//
//  RecipeAmountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI

struct RecipeAmountViewDelegate {
    let recipe: RecipeTemplateModel
    let onPick: (MealItemModel) -> Void
}

struct RecipeAmountView: View {
    @State var viewModel: RecipeAmountViewModel

    let delegate: RecipeAmountViewDelegate

    var body: some View {
        Form {
            Section("Servings") {
                TextField("Servings", text: $viewModel.servingsText)
                    .keyboardType(.decimalPad)
            }
            Section("Estimated Macros (per serving)") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(viewModel.baseCalories(recipe: delegate.recipe).map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(viewModel.baseProtein(recipe: delegate.recipe).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(viewModel.baseCarbs(recipe: delegate.recipe).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(viewModel.baseFat(recipe: delegate.recipe).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(delegate.recipe.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    viewModel.add(
                        recipe: delegate.recipe,
                        onConfirm: delegate.onPick
                    )
                }
                    .disabled(viewModel.servings <= 0)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.recipeAmountView(
        delegate: RecipeAmountViewDelegate(
            recipe: RecipeTemplateModel.mock,
            onPick: { meal in
                print(meal.id)
            }
        )
    )
}
