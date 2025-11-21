//
//  RecipeStartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import CustomRouting

struct RecipeStartViewDelegate {
    var recipe: RecipeTemplateModel
}

struct RecipeStartView: View {

    @State var viewModel: RecipeStartViewModel

    var delegate: RecipeStartViewDelegate

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

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.recipeStartView(router: router, delegate: RecipeStartViewDelegate(recipe: .mock))
    }
}
