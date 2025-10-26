//
//  NutritionViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol NutritionInteractor {
    
}

extension CoreInteractor: NutritionInteractor { }

@Observable
@MainActor
class NutritionViewModel {
    private let interactor: NutritionInteractor
    
    var presentationMode: NutritionPresentationMode = .log
    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    var showAlert: AnyAppAlert?
    var isShowingInspector: Bool = false
    private(set) var searchIngredientTask: Task<Void, Never>?
    private(set) var myIngredients: [IngredientTemplateModel] = []
    private(set) var favouriteIngredients: [IngredientTemplateModel] = []
    private(set) var bookmarkedIngredients: [IngredientTemplateModel] = []
    private(set) var ingredients: [IngredientTemplateModel] = []
    var selectedIngredientTemplate: IngredientTemplateModel?
    var showCreateIngredient: Bool = false
    private(set) var searchRecipeTask: Task<Void, Never>?
    private(set) var myRecipes: [RecipeTemplateModel] = []
    private(set) var favouriteRecipes: [RecipeTemplateModel] = []
    private(set) var bookmarkedRecipes: [RecipeTemplateModel] = []
    private(set) var recipes: [RecipeTemplateModel] = []
    var selectedRecipeTemplate: RecipeTemplateModel?
    var showCreateRecipe: Bool = false
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    var showNotifications: Bool = false
    
    init(
        interactor: NutritionInteractor
    ) {
        self.interactor = interactor
    }
    
    func onNotificationsPressed() {
        showNotifications = true
    }
    
    enum NutritionPresentationMode {
        case log
        case recipes
        case ingredients
    }
}
