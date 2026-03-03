//
//  IngredientTemplateManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

@Observable
@MainActor
class IngredientTemplateManager {
    
    private let ingredientTemplateSyncEngine: CollectionSyncEngine<IngredientTemplateModel>
    
    var ingredientTemplates: [IngredientTemplateModel] {
        ingredientTemplateSyncEngine.currentCollection
    }
    
    init(ingredientTemplateSyncEngine: CollectionSyncEngine<IngredientTemplateModel>) {
        self.ingredientTemplateSyncEngine = ingredientTemplateSyncEngine
    }
    
    func signIn() async {
        await ingredientTemplateSyncEngine.startListening()
    }

    func signOut() {
        ingredientTemplateSyncEngine.stopListening()
    }

    // MARK: - Method Aliases for Backward Compatibility
    
    func saveIngredientTemplate(_ ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        var ingredient = ingredient
        if let image {
            let path = "ingredient_templates/\(ingredient.id)"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            ingredient.updateImageURL(imageUrl: url.absoluteString)
        }
        try await ingredientTemplateSyncEngine.saveDocument(ingredient)
    }
    
    func deleteIngredientTemplate(ingredientId id: String) async throws {
        try await ingredientTemplateSyncEngine.deleteDocument(id: id)
    }
    
    func deleteAllIngredientTemplates(id: String) async throws {
        // TODO: Add delete all ingredients here
    }

}
 
extension CoreInteractor {
    // MARK: IngredientTemplateManager
    
    var ingredientTemplates: [IngredientTemplateModel] {
        ingredientTemplateManager.ingredientTemplates
    }
    
    func saveIngredientTemplate(_ ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        try await ingredientTemplateManager.saveIngredientTemplate(ingredient, image: image)
    }
    
    func deleteIngredientTempalte(ingredientId id: String) async throws {
        try await ingredientTemplateManager.deleteIngredientTemplate(ingredientId: id)
    }
}
