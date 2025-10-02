//
//  RecipeStartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI

struct RecipeStartView: View {
    
    var recipe: RecipeTemplateModel
    var body: some View {
        List {
            Section("Ingredients") {
                ForEach(recipe.ingredients) { wrapper in
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
    RecipeStartView(recipe: .mock)
}
