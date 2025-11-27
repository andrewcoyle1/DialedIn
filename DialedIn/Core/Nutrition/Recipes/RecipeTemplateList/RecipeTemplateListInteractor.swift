//
//  RecipeTemplateListInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol RecipeTemplateListInteractor {
    func getRecipeTemplates(ids: [String], limitTo: Int) async throws -> [RecipeTemplateModel]
}

extension CoreInteractor: RecipeTemplateListInteractor { }
