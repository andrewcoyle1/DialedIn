//
//  AddIngredientModalInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AddIngredientModalInteractor {
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel]
    func getAllLocalIngredientTemplates() throws -> [IngredientTemplateModel]
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel]
}

extension CoreInteractor: AddIngredientModalInteractor { }
