//
//  RecipeStartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI

struct RecipeStartViewDelegate {
    var recipe: RecipeTemplateModel
}

struct RecipeStartView: View {
    
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
    RecipeStartView(delegate: RecipeStartViewDelegate(recipe: .mock))
}
