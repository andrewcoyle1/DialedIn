//
//  NutritionLibraryPickerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

protocol NutritionLibraryPickerInteractor: Sendable {
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel]
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel]
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: NutritionLibraryPickerInteractor, @unchecked Sendable { }

@MainActor
protocol NutritionLibraryPickerRouter {
    func showIngredientAmountView(delegate: IngredientAmountViewDelegate)
    func showRecipeAmountView(delegate: RecipeAmountViewDelegate)
    func showDevSettingsView()
    func showAlert(error: Error)
    func dismissScreen()
}

extension CoreRouter: NutritionLibraryPickerRouter { }

@Observable
@MainActor
class NutritionLibraryPickerViewModel {
    private let interactor: NutritionLibraryPickerInteractor
    private let router: NutritionLibraryPickerRouter

    var mode: PickerMode = .ingredients
    var searchText: String = ""
    private(set) var isLoading: Bool = false
    private(set) var ingredients: [IngredientTemplateModel] = []
    private(set) var recipes: [RecipeTemplateModel] = []

    init(
        interactor: NutritionLibraryPickerInteractor,
        router: NutritionLibraryPickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadInitial() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let topIngredients = interactor.getTopIngredientTemplatesByClicks(limitTo: 20)
            async let topRecipes = interactor.getTopRecipeTemplatesByClicks(limitTo: 20)
            let (ings, recs) = try await (topIngredients, topRecipes)
            ingredients = ings
            recipes = recs
        } catch {
            router.showAlert(error: error)
        }
    }
    
    func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        isLoading = true
        defer { isLoading = false }
        do {
            if trimmed.isEmpty {
                await loadInitial()
                return
            }
            switch mode {
            case .ingredients:
                ingredients = try await interactor.getIngredientTemplatesByName(name: trimmed)
            case .recipes:
                recipes = try await interactor.getRecipeTemplatesByName(name: trimmed)
            }
        } catch {
            router.showAlert(error: error)
        }
    }

    func navToIngredientAmount(_ ingredient: IngredientTemplateModel, onPick: @escaping (MealItemModel) -> Void) {
        router.showIngredientAmountView(delegate: IngredientAmountViewDelegate(ingredient: ingredient, onPick: onPick))
    }

    func navToRecipeAmount(_ recipe: RecipeTemplateModel, onPick: @escaping (MealItemModel) -> Void) {
        router.showRecipeAmountView(delegate: RecipeAmountViewDelegate(recipe: recipe, onPick: onPick))
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
