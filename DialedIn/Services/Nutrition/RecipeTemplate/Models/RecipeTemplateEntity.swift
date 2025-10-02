//
//  RecipeTemplateEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftData

@Model
class RecipeTemplateEntity {
    @Attribute(.unique) var recipeTemplateId: String
    var authorId: String?
    var name: String
    var recipeDescription: String?
    var imageURL: String?
    var dateCreated: Date
    var dateModified: Date
    // Persist recipe ingredients as JSON to include amount and unit
    var ingredientsJSON: String
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?
    
    init(from model: RecipeTemplateModel) {
        self.recipeTemplateId = model.recipeId
        self.authorId = model.authorId
        self.name = model.name
        self.recipeDescription = model.description
        self.imageURL = model.imageURL
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        if let data = try? JSONEncoder().encode(model.ingredients), let json = String(data: data, encoding: .utf8) {
            self.ingredientsJSON = json
        } else {
            self.ingredientsJSON = "[]"
        }
        self.clickCount = model.clickCount
        self.bookmarkCount = model.bookmarkCount
        self.favouriteCount = model.favouriteCount
    }
    
    @MainActor
    func toModel() -> RecipeTemplateModel {
        let ingredients: [RecipeIngredientModel] = {
            guard let data = ingredientsJSON.data(using: .utf8) else { return [] }
            return (try? JSONDecoder().decode([RecipeIngredientModel].self, from: data)) ?? []
        }()
        return RecipeTemplateModel(
            id: recipeTemplateId,
            authorId: authorId ?? "",
            name: name,
            description: recipeDescription,
            imageURL: imageURL,
            dateCreated: dateCreated,
            dateModified: dateModified,
            ingredients: ingredients,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }
}
