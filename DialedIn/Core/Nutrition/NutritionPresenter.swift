//
//  NutritionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class NutritionPresenter {
    private let interactor: NutritionInteractor
    private let router: NutritionRouter

    var presentationMode: NutritionPresentationMode = .log
    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    var isShowingInspector: Bool = false
    private(set) var searchIngredientTask: Task<Void, Never>?
    private(set) var myIngredients: [IngredientTemplateModel] = []
    private(set) var favouriteIngredients: [IngredientTemplateModel] = []
    private(set) var bookmarkedIngredients: [IngredientTemplateModel] = []
    private(set) var ingredients: [IngredientTemplateModel] = []
    var selectedIngredientTemplate: IngredientTemplateModel?
    private(set) var searchRecipeTask: Task<Void, Never>?
    private(set) var myRecipes: [RecipeTemplateModel] = []
    private(set) var favouriteRecipes: [RecipeTemplateModel] = []
    private(set) var bookmarkedRecipes: [RecipeTemplateModel] = []
    private(set) var recipes: [RecipeTemplateModel] = []
    var selectedRecipeTemplate: RecipeTemplateModel?
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    var showNotifications: Bool = false
    
    init(
        interactor: NutritionInteractor,
        router: NutritionRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onNotificationsPressed() {
        router.showNotificationsView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onCreateIngredientPressed() {
        router.showCreateIngredientView()
    }

    func onCreateRecipePressed() {
        router.showCreateRecipeView()
    }

    enum NutritionPresentationMode {
        case log
        case recipes
        case ingredients
    }
}
