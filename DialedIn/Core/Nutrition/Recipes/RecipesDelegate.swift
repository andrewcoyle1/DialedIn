//
//  RecipesDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

struct RecipesDelegate {
    var showCreateRecipe: Binding<Bool>
    var selectedIngredientTemplate: Binding<IngredientTemplateModel?>
    var selectedRecipeTemplate: Binding<RecipeTemplateModel?>
    var isShowingInspector: Binding<Bool>
}
