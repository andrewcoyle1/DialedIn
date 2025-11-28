//
//  IngredientTemplateListInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol IngredientTemplateListInteractor {
    func getIngredientTemplates(ids: [String], limitTo: Int) async throws -> [IngredientTemplateModel]
}

extension CoreInteractor: IngredientTemplateListInteractor { }
