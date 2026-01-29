//
//  RemoteTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

protocol RemoteIngredientTemplateService {
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel
    func getIngredientTemplates(ids: [String], limitTo: Int) async throws -> [IngredientTemplateModel]
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel]
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel]
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel]
    func incrementIngredientTemplateInteraction(id: String) async throws
    func removeAuthorIdFromIngredientTemplate(id: String) async throws
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws
    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws
}
