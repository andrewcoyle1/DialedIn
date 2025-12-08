//
//  RecipeStartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct RecipeStartView: View {

    @State var presenter: RecipeStartPresenter

    var delegate: RecipeStartDelegate

    var body: some View {
        List {
            Section("Ingredients") {
                ForEach(delegate.recipe.ingredients) { wrapper in
                    HStack {
                        Text(wrapper.ingredient.name)
                        Spacer()
                        Text("\(Int(wrapper.amount)) \(unitString(wrapper.unit))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    private func unitString(_ unit: IngredientAmountUnit) -> String {
        switch unit {
        case .grams: return "g"
        case .milliliters: return "ml"
        case .units: return "units"
        }
    }
}

extension CoreBuilder {
    func recipeStartView(router: AnyRouter, delegate: RecipeStartDelegate) -> some View {
        RecipeStartView(
            presenter: RecipeStartPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showStartRecipeView(delegate: RecipeStartDelegate) {
        router.showScreen(.push) { router in
            builder.recipeStartView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.recipeStartView(router: router, delegate: RecipeStartDelegate(recipe: .mock))
    }
}
