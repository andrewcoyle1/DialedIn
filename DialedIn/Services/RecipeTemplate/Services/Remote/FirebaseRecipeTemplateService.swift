//
//  FirebaseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseRecipeTemplateService: RemoteRecipeTemplateService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("recipe_templates")
    }
    
    func createRecipeTemplate(recipe: RecipeTemplateModel, image: PlatformImage?) async throws {
        // Work on a mutable copy so any image URL updates are persisted
        var recipeToSave = recipe
        
        if let image {
            // Upload the image
            let path = "recipe_templates/\(recipe.id)"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            
            // Persist the download URL on the ingredient that will be saved
            recipeToSave.updateImageURL(imageUrl: url.absoluteString)
        }
        
        // Upload the (possibly updated) ingredient
        try collection.document(recipeToSave.id).setData(from: recipeToSave, merge: true)
        // Also persist lowercased name for case-insensitive prefix search
        try await collection.document(
            recipeToSave.id).setData([
            "name_lower": recipeToSave.name.lowercased()
        ], merge: true)
    }
    
    func getRecipeTemplate(id: String) async throws -> RecipeTemplateModel {
        try await collection.getDocument(id: id)
    }
    
    func getRecipeTemplates(ids: [String], limitTo: Int = 20) async throws -> [RecipeTemplateModel] {
        try await collection
            .getDocuments(ids: ids)
            .shuffled()
            .first(upTo: limitTo) ?? []
    }
    
    func getRecipeTemplatesByName(name: String) async throws -> [RecipeTemplateModel] {
        let lower = name.lowercased()
        // Case-insensitive prefix search using range on a lowercased field
        return try await collection
            .order(by: "name_lower")
            .start(at: [lower])
            .end(at: [lower + "\u{f8ff}"])
            .limit(to: 25)
            .getAllDocuments()
    }
    
    func getRecipeTemplatesForAuthor(authorId: String) async throws -> [RecipeTemplateModel] {
        try await collection
            .whereField(IngredientTemplateModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: IngredientTemplateModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
    }
    
    func getTopRecipeTemplatesByClicks(limitTo: Int) async throws -> [RecipeTemplateModel] {
        try await collection
            .order(by: RecipeTemplateModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: limitTo)
            .getAllDocuments()
    }
    
    func incrementRecipeTemplateInteraction(id: String) async throws {
        try await collection
            .document(id)
            .updateData([
                RecipeTemplateModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
    func removeAuthorIdFromRecipeTemplate(id: String) async throws {
        try await collection.document(id).updateData([
            RecipeTemplateModel.CodingKeys.authorId.rawValue: NSNull()
        ])
    }
    
    func removeAuthorIdFromAllRecipeTemplates(id: String) async throws {
        let recipes = try await getRecipeTemplatesForAuthor(authorId: id)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for recipe in recipes {
                group.addTask {
                    try await removeAuthorIdFromRecipeTemplate(id: recipe.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func bookmarkRecipeTemplate(id: String, isBookmarked: Bool) async throws {
        try await collection.document(id).updateData([
            RecipeTemplateModel.CodingKeys.bookmarkCount.rawValue: FieldValue.increment(Int64(isBookmarked ? 1 : -1))
        ])
    }

    func favouriteRecipeTemplate(id: String, isFavourited: Bool) async throws {
        try await collection.document(id).updateData([
            RecipeTemplateModel.CodingKeys.favouriteCount.rawValue: FieldValue.increment(Int64(isFavourited ? 1 : -1))
        ])
    }
}
