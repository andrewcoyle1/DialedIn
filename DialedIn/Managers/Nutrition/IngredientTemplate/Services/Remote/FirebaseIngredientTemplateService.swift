//
//  FirebaseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import FirebaseFirestore

struct FirebaseIngredientTemplateService: RemoteIngredientTemplateService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("ingredient_templates")
    }
    
    func createIngredientTemplate(ingredient: IngredientTemplateModel, image: PlatformImage?) async throws {
        #if DEBUG
        print("[FirebaseIngredientTemplateService] create start id=\(ingredient.id) hasImage=\(image != nil)")
        #endif
        do {
            // Work on a mutable copy so any image URL updates are persisted
            var ingredientToSave = ingredient
            
            if let image {
                // Upload the image
                let path = "ingredient_templates/\(ingredient.id)/image.jpg"
                let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
                
                // Persist the download URL on the ingredient that will be saved
                ingredientToSave.updateImageURL(imageUrl: url.absoluteString)
            }
            
            // Upload the (possibly updated) ingredient
            try collection.document(ingredientToSave.id).setData(from: ingredientToSave, merge: true)
            // Also persist lowercased name for case-insensitive prefix search
            try await collection.document(ingredientToSave.id).setData([
                "name_lower": ingredientToSave.name.lowercased()
            ], merge: true)
            #if DEBUG
            print("[FirebaseIngredientTemplateService] create success id=\(ingredient.id)")
            #endif
        } catch {
            #if DEBUG
            print("[FirebaseIngredientTemplateService] create fail id=\(ingredient.id) error=\(error)")
            #endif
            throw error
        }
    }
    
    func getIngredientTemplate(id: String) async throws -> IngredientTemplateModel {
        try await collection.getDocument(id: id)
    }
    
    func getIngredientTemplates(ids: [String], limitTo: Int = 20) async throws -> [IngredientTemplateModel] {
        let documents: [IngredientTemplateModel] = try await collection.getDocuments(ids: ids)
        return Array(documents
            .shuffled()
            .prefix(limitTo))
    }
    
    func getIngredientTemplatesByName(name: String) async throws -> [IngredientTemplateModel] {
        let lower = name.lowercased()
        // Case-insensitive prefix search using range on a lowercased field
        return try await collection
            .order(by: "name_lower")
            .start(at: [lower])
            .end(at: [lower + "\u{f8ff}"])
            .limit(to: 25)
            .getAllDocuments()
    }
    
    func getIngredientTemplatesForAuthor(authorId: String) async throws -> [IngredientTemplateModel] {
        try await collection
            .whereField(IngredientTemplateModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: IngredientTemplateModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
    }
    
    func getTopIngredientTemplatesByClicks(limitTo: Int) async throws -> [IngredientTemplateModel] {
        try await collection
            .order(by: IngredientTemplateModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: limitTo)
            .getAllDocuments()
    }
    
    func incrementIngredientTemplateInteraction(id: String) async throws {
        try await collection
            .document(id)
            .updateData([
            IngredientTemplateModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
    func removeAuthorIdFromIngredientTemplate(id: String) async throws {
        try await collection.document(id).updateData([
            IngredientTemplateModel.CodingKeys.authorId.rawValue: NSNull()
        ])
    }
    
    func removeAuthorIdFromAllIngredientTemplates(id: String) async throws {
        let ingredients = try await getIngredientTemplatesForAuthor(authorId: id)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for ingredient in ingredients {
                group.addTask {
                    try await removeAuthorIdFromIngredientTemplate(id: ingredient.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func bookmarkIngredientTemplate(id: String, isBookmarked: Bool) async throws {
        try await collection.document(id).updateData([
            IngredientTemplateModel.CodingKeys.bookmarkCount.rawValue: FieldValue.increment(Int64(isBookmarked ? 1 : -1))
        ])
    }

    func favouriteIngredientTemplate(id: String, isFavourited: Bool) async throws {
        try await collection.document(id).updateData([
            IngredientTemplateModel.CodingKeys.favouriteCount.rawValue: FieldValue.increment(Int64(isFavourited ? 1 : -1))
        ])
    }
}
