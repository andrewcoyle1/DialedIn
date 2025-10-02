//
//  IngredientTemplateEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftData

@Model
class IngredientTemplateEntity {
    @Attribute(.unique) var ingredientTemplateId: String
    var authorId: String?
    var name: String
    var ingredientDescription: String?
    var measurementMethod: MeasurementMethod
    var calories: Double?
    var protein: Double?
    var carbs: Double?
    var fat: Double?
    var fiber: Double?
    var sugar: Double?
    var sodiumMg: Double?
    var potassiumMg: Double?
    var calciumMg: Double?
    var ironMg: Double?
    var vitaminCMg: Double?
    var vitaminDMcg: Double?
    var magnesiumMg: Double?
    var zincMg: Double?
    var imageURL: String?
    var dateCreated: Date
    var dateModified: Date
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?
    
    init(from model: IngredientTemplateModel) {
        self.ingredientTemplateId = model.ingredientId
        self.authorId = model.authorId
        self.name = model.name
        self.ingredientDescription = model.description
        self.measurementMethod = model.measurementMethod
        self.calories = model.calories
        self.protein = model.protein
        self.carbs = model.carbs
        self.fat = model.fat
        self.fiber = model.fiber
        self.sugar = model.sugar
        self.sodiumMg = model.sodiumMg
        self.potassiumMg = model.potassiumMg
        self.calciumMg = model.calciumMg
        self.ironMg = model.ironMg
        self.vitaminCMg = model.vitaminCMg
        self.vitaminDMcg = model.vitaminDMcg
        self.magnesiumMg = model.magnesiumMg
        self.zincMg = model.zincMg
        self.imageURL = model.imageURL
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.clickCount = model.clickCount
        self.bookmarkCount = model.bookmarkCount
        self.favouriteCount = model.favouriteCount
    }
    
    @MainActor
    func toModel() -> IngredientTemplateModel {
        IngredientTemplateModel(
            ingredientId: ingredientTemplateId,
            authorId: authorId,
            name: name,
            description: ingredientDescription,
            measurementMethod: measurementMethod,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodiumMg: sodiumMg,
            potassiumMg: potassiumMg,
            calciumMg: calciumMg,
            ironMg: ironMg,
            vitaminCMg: vitaminCMg,
            vitaminDMcg: vitaminDMcg,
            magnesiumMg: magnesiumMg,
            zincMg: zincMg,
            imageURL: imageURL,
            dateCreated: dateCreated,
            dateModified: dateModified,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }
}
