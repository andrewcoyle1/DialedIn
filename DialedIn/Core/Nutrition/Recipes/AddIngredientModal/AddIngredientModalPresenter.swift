//
//  AddIngredientModalPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class AddIngredientModalPresenter {
    private let interactor: AddIngredientModalInteractor
    private let router: AddIngredientModalRouter

    var searchText: String = ""
    
    var ingredientTemplates: [IngredientTemplateModel] {
        interactor.ingredientTemplates
    }
    
    init(
        interactor: AddIngredientModalInteractor,
        router: AddIngredientModalRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onIngredientPressed(ingredient: IngredientTemplateModel, selectedIngredients: inout [IngredientTemplateModel]) {
        if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
            selectedIngredients.remove(at: index)
        } else {
            selectedIngredients.append(ingredient)
        }
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
    
#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif
}
