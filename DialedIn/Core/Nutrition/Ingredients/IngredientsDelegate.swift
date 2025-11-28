//
//  IngredientsDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

struct IngredientsDelegate {
    var isShowingInspector: Binding<Bool>
    var selectedIngredientTemplate: Binding<IngredientTemplateModel?>
    var selectedRecipeTemplate: Binding<RecipeTemplateModel?>
    var showCreateIngredient: Binding<Bool>
}
