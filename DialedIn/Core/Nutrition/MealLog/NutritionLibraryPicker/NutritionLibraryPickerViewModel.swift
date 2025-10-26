//
//  NutritionLibraryPickerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

protocol NutritionLibraryPickerInteractor: Sendable {
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel]
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel]
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel]
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel]
}

extension CoreInteractor: NutritionLibraryPickerInteractor, @unchecked Sendable { }

@Observable
@MainActor
class NutritionLibraryPickerViewModel {
    private let interactor: NutritionLibraryPickerInteractor
    
    var mode: PickerMode = .ingredients
    var searchText: String = ""
    private(set) var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    private(set) var ingredients: [IngredientTemplateModel] = []
    private(set) var recipes: [RecipeTemplateModel] = []

    let onPick: (MealItemModel) -> Void
    
    init(
        interactor: NutritionLibraryPickerInteractor,
        onPick: @escaping (MealItemModel) -> Void
    ) {
        self.interactor = interactor
        self.onPick = onPick
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
            showAlert = AnyAppAlert(error: error)
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
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    enum PickerMode: String, CaseIterable, Hashable {
        case ingredients
        case recipes
    }
}
