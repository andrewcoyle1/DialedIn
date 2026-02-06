//
//  RecipeAmountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct RecipeAmountDelegate {
    let recipe: RecipeTemplateModel
    let onPick: (MealItemModel) -> Void
}

struct RecipeAmountView: View {
    @State var presenter: RecipeAmountPresenter

    let delegate: RecipeAmountDelegate

    var body: some View {
        Form {
            Section("Servings") {
                TextField("Servings", text: $presenter.servingsText)
                    .keyboardType(.decimalPad)
            }
            Section("Estimated Macros (per serving)") {
                HStack {
                    Text("Calories")
                    Spacer()
                    Text(presenter.baseCalories(recipe: delegate.recipe).map { String(Int(round($0))) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Protein")
                    Spacer()
                    Text(presenter.baseProtein(recipe: delegate.recipe).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Carbs")
                    Spacer()
                    Text(presenter.baseCarbs(recipe: delegate.recipe).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Fat")
                    Spacer()
                    Text(presenter.baseFat(recipe: delegate.recipe).map { String(format: "%.1f g", $0) } ?? "-")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(delegate.recipe.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    presenter.add(
                        recipe: delegate.recipe,
                        onConfirm: delegate.onPick
                    )
                }
                    .disabled(presenter.servings <= 0)
            }
        }
    }
}

extension CoreBuilder {
    func recipeAmountView(router: AnyRouter, delegate: RecipeAmountDelegate) -> some View {
        RecipeAmountView(
            presenter: RecipeAmountPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showRecipeAmountView(delegate: RecipeAmountDelegate) {
        router.showScreen(.push) { router in
            builder.recipeAmountView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.recipeAmountView(
            router: router, 
            delegate: RecipeAmountDelegate(
                recipe: RecipeTemplateModel.mock,
                onPick: { meal in
                    print(meal.id)
                }
            )
        )
    }
}
