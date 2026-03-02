//
//  NutritionLibraryPickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class NutritionLibraryPickerPresenter {
    private let interactor: NutritionLibraryPickerInteractor
    private let router: NutritionLibraryPickerRouter

    var mode: PickerMode = .ingredients
    var searchText: String = ""
    private(set) var isLoading: Bool = false
    private(set) var recipes: [RecipeTemplateModel] = []

    var ingredientTemplates: [IngredientTemplateModel] {
        interactor.ingredientTemplates
            .filter {
                $0.name == searchText
            }
    }
    
    init(
        interactor: NutritionLibraryPickerInteractor,
        router: NutritionLibraryPickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func navToIngredientAmount(_ ingredient: IngredientTemplateModel, onPick: @escaping (MealItemModel) -> Void) {
        router.showIngredientAmountView(delegate: IngredientAmountDelegate(ingredient: ingredient, onPick: onPick))
    }

    func navToRecipeAmount(_ recipe: RecipeTemplateModel, onPick: @escaping (MealItemModel) -> Void) {
        router.showRecipeAmountView(delegate: RecipeAmountDelegate(recipe: recipe, onPick: onPick))
    }

    enum PickerMode: String, CaseIterable, Hashable {
        case ingredients
        case recipes
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "NutritionLibrary_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }

    func dismissScreen() {
        router.dismissScreen()
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
