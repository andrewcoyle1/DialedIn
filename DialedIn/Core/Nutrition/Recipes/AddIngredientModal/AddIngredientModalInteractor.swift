//
//  AddIngredientModalInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol AddIngredientModalInteractor: GlobalInteractor {
    var ingredientTemplates: [IngredientTemplateModel] { get }
}

extension CoreInteractor: AddIngredientModalInteractor { }
