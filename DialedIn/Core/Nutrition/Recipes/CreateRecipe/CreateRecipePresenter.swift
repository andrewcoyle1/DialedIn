//
//  CreateRecipePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class CreateRecipePresenter {
    private let interactor: CreateRecipeInteractor
    private let router: CreateRecipeRouter

    var recipeName: String = ""
    var servingQuantity: Double?
    var recipeTotalWeight: Double?
    var showAllNutrition: Bool = false
    
    var ingredients: [RecipeIngredientModel] = []

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var canSave: Bool {
        !recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        interactor: CreateRecipeInteractor,
        router: CreateRecipeRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func onDismissPressed() {
        router.dismissScreen()
    }

    #if DEV || MOCK
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    #endif

    func onNextPressed() {
        router.showRecipePreparationView(delegate: RecipePreparationDelegate())
    }
        
    func onAddIngredientPressed() {
        let selectedIngredientsBinding = Binding<[FoodModel]>(
            get: { [weak self] in
                guard let self = self else { return [] }
                return self.ingredients.map { $0.ingredient }
            },
            set: { [weak self] newTemplates in
                guard let self = self else { return }
                
                var currentMap = Dictionary(
                    uniqueKeysWithValues: self.ingredients.map {
                        ($0.ingredient.id, $0)
                    }
                )
                
                for tmpl in newTemplates where currentMap[tmpl.id] == nil {
                    currentMap[tmpl.id] = RecipeIngredientModel(
                        ingredient: tmpl,
                        amount: 1
                    )
                }
                
                let newIds = Set(newTemplates.map { $0.id })
                
                currentMap = currentMap.filter { newIds.contains($0.key) }
                
                self.ingredients = Array(currentMap.values)
            }
        )
        
        router.showAddIngredientView(
            delegate: AddFoodDelegate(
                selectedIngredients: selectedIngredientsBinding
            )
        )
    }
}
