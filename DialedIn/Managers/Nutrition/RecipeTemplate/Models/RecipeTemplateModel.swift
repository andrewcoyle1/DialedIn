//
//  RecipeTemplate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

struct RecipeTemplateModel: @MainActor TemplateModel {
    var id: String {
        recipeId
    }
    
    let recipeId: String
    let authorId: String?
    let name: String
    let description: String?
    private(set) var imageURL: String?
    let dateCreated: Date
    let dateModified: Date
    var ingredients: [RecipeIngredientModel]
    let clickCount: Int?
    let bookmarkCount: Int?
    let favouriteCount: Int?
    
    init(
        id: String,
        authorId: String,
        name: String,
        description: String? = nil,
        imageURL: String? = nil,
        dateCreated: Date,
        dateModified: Date,
        ingredients: [RecipeIngredientModel] = [],
        clickCount: Int? = 0,
        bookmarkCount: Int? = 0,
        favouriteCount: Int? = 0
    ) {
        self.recipeId = id
        self.authorId = authorId
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.ingredients = ingredients
        self.clickCount = clickCount
        self.bookmarkCount = bookmarkCount
        self.favouriteCount = favouriteCount
    }
    
    mutating func updateImageURL(imageUrl: String) {
        self.imageURL = imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case recipeId = "recipe_id"
        case authorId = "author_id"
        case name = "name"
        case description = "description"
        case imageURL = "image_url"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case ingredients = "ingredients"
        case clickCount = "click_count"
        case bookmarkCount = "bookmark_count"
        case favouriteCount = "favourite_count"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "recipe_\(CodingKeys.recipeId.rawValue)": recipeId,
            "recipe_\(CodingKeys.authorId.rawValue)": authorId,
            "recipe_\(CodingKeys.name.rawValue)": name,
            "recipe_\(CodingKeys.description.rawValue)": description,
            "recipe_\(CodingKeys.imageURL.rawValue)": imageURL,
            "recipe_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "recipe_\(CodingKeys.dateModified.rawValue)": dateModified,
            "recipe_\(CodingKeys.ingredients.rawValue)": ingredients.map { $0.ingredient.ingredientId },
            "recipe_\(CodingKeys.clickCount.rawValue)": clickCount,
            "recipe_\(CodingKeys.bookmarkCount.rawValue)": bookmarkCount,
            "recipe_\(CodingKeys.favouriteCount.rawValue)": favouriteCount
        ]
        return dict.compactMapValues { $0 }
    }
    
    static func newRecipeTemplate(
        name: String,
        authorId: String,
        description: String? = nil,
        imageURL: String? = nil,
        ingredients: [RecipeIngredientModel] = [],
        clickCount: Int? = 0,
        bookmarkCount: Int? = 0,
        favouriteCount: Int? = 0
    ) -> Self {
        RecipeTemplateModel(
            id: UUID().uuidString,
            authorId: authorId,
            name: name,
            description: description,
            imageURL: imageURL,
            dateCreated: .now,
            dateModified: .now,
            ingredients: ingredients,
            clickCount: clickCount,
            bookmarkCount: bookmarkCount,
            favouriteCount: favouriteCount
        )
    }
    
    static var mock: RecipeTemplateModel {
        mocks[0]
    }
    
    static var mocks: [RecipeTemplateModel] {
        [
            
        RecipeTemplateModel(
            id: "recipe1",
            authorId: "user1",
            name: "Classic Margherita Pizza",
            description: "A simple and delicious pizza with fresh mozzarella, tomatoes, and basil.",
            imageURL: Constants.randomImage,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 10),
            dateModified: Date(timeIntervalSinceNow: -86400 * 5),
            ingredients: [
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing1",
                    authorId: "user1",
                    name: "Pizza Dough",
                    description: "Homemade classic pizza dough.",
                    measurementMethod: .weight,
                    calories: 250,
                    protein: 7,
                    carbs: 50,
                    fatTotal: 2,
                    fiber: 2,
                    sugar: 1,
                    sodiumMg: 400,
                    potassiumMg: 80,
                    calciumMg: 20,
                    ironMg: 1.5,
                    vitaminCMg: 0,
                    vitaminDMcg: 0,
                    magnesiumMg: 10,
                    zincMg: 0.5,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 10),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 5),
                    clickCount: 5
                ),
                    amount: 200,
                    unit: .grams
                ),
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing2",
                    authorId: "user1",
                    name: "Fresh Mozzarella",
                    description: "Creamy mozzarella cheese.",
                    measurementMethod: .weight,
                    calories: 80,
                    protein: 6,
                    carbs: 1,
                    fatTotal: 6,
                    fiber: 0,
                    sugar: 1,
                    sodiumMg: 150,
                    potassiumMg: 30,
                    calciumMg: 120,
                    ironMg: 0.1,
                    vitaminCMg: 0,
                    vitaminDMcg: 0.2,
                    magnesiumMg: 8,
                    zincMg: 0.4,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 10),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 5),
                    clickCount: 3
                ),
                    amount: 100,
                    unit: .grams
                ),
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing3",
                    authorId: "user1",
                    name: "Tomato Sauce",
                    description: "Rich tomato sauce with herbs.",
                    measurementMethod: .weight,
                    calories: 30,
                    protein: 1,
                    carbs: 6,
                    fatTotal: 0,
                    fiber: 1,
                    sugar: 4,
                    sodiumMg: 200,
                    potassiumMg: 180,
                    calciumMg: 15,
                    ironMg: 0.3,
                    vitaminCMg: 8,
                    vitaminDMcg: 0,
                    magnesiumMg: 6,
                    zincMg: 0.1,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 10),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 5),
                    clickCount: 2
                ),
                    amount: 150,
                    unit: .milliliters
                )
            ],
            bookmarkCount: 22,
            favouriteCount: 8
        ),
        RecipeTemplateModel(
            id: "recipe2",
            authorId: "user2",
            name: "Protein Pancakes",
            description: "Fluffy pancakes packed with protein for a healthy breakfast.",
            imageURL: nil,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 20),
            dateModified: Date(timeIntervalSinceNow: -86400 * 15),
            ingredients: [
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing4",
                    authorId: "user2",
                    name: "Oat Flour",
                    description: "Ground oats for a healthy base.",
                    measurementMethod: .weight,
                    calories: 150,
                    protein: 5,
                    carbs: 27,
                    fatTotal: 3,
                    fiber: 4,
                    sugar: 1,
                    sodiumMg: 2,
                    potassiumMg: 120,
                    calciumMg: 20,
                    ironMg: 1.2,
                    vitaminCMg: 0,
                    vitaminDMcg: 0,
                    magnesiumMg: 40,
                    zincMg: 1,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 20),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 15),
                    clickCount: 4
                ),
                    amount: 80,
                    unit: .grams
                ),
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing5",
                    authorId: "user2",
                    name: "Whey Protein",
                    description: "Vanilla flavored whey protein powder.",
                    measurementMethod: .weight,
                    calories: 120,
                    protein: 24,
                    carbs: 3,
                    fatTotal: 1,
                    fiber: 0,
                    sugar: 2,
                    sodiumMg: 50,
                    potassiumMg: 100,
                    calciumMg: 130,
                    ironMg: 0.2,
                    vitaminCMg: 0,
                    vitaminDMcg: 0,
                    magnesiumMg: 10,
                    zincMg: 0.2,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 20),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 15),
                    clickCount: 6
                ),
                    amount: 30,
                    unit: .grams
                )
            ],
            bookmarkCount: 15,
            favouriteCount: 4
        ),
        RecipeTemplateModel(
            id: "recipe3",
            authorId: "user3",
            name: "Vegan Buddha Bowl",
            description: "A nourishing bowl with grains, greens, and plant protein.",
            imageURL: Constants.randomImage,
            dateCreated: Date(timeIntervalSinceNow: -86400 * 5),
            dateModified: Date(timeIntervalSinceNow: -86400 * 2),
            ingredients: [
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing6",
                    authorId: "user3",
                    name: "Quinoa",
                    description: "Fluffy cooked quinoa.",
                    measurementMethod: .weight,
                    calories: 120,
                    protein: 4,
                    carbs: 21,
                    fatTotal: 2,
                    fiber: 3,
                    sugar: 0,
                    sodiumMg: 7,
                    potassiumMg: 120,
                    calciumMg: 15,
                    ironMg: 1.5,
                    vitaminCMg: 0,
                    vitaminDMcg: 0,
                    magnesiumMg: 30,
                    zincMg: 1,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 5),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 2),
                    clickCount: 7
                ),
                    amount: 150,
                    unit: .grams
                ),
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing7",
                    authorId: "user3",
                    name: "Chickpeas",
                    description: "Roasted chickpeas for protein.",
                    measurementMethod: .weight,
                    calories: 140,
                    protein: 7,
                    carbs: 23,
                    fatTotal: 2,
                    fiber: 6,
                    sugar: 2,
                    sodiumMg: 120,
                    potassiumMg: 180,
                    calciumMg: 40,
                    ironMg: 2,
                    vitaminCMg: 1,
                    vitaminDMcg: 0,
                    magnesiumMg: 25,
                    zincMg: 1.3,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 5),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 2),
                    clickCount: 5
                ),
                    amount: 100,
                    unit: .grams
                ),
                RecipeIngredientModel(
                    ingredient: IngredientTemplateModel(
                    ingredientId: "ing8",
                    authorId: "user3",
                    name: "Spinach",
                    description: "Fresh baby spinach leaves.",
                    measurementMethod: .weight,
                    calories: 20,
                    protein: 2,
                    carbs: 3,
                    fatTotal: 0,
                    fiber: 2,
                    sugar: 0,
                    sodiumMg: 65,
                    potassiumMg: 167,
                    calciumMg: 30,
                    ironMg: 0.8,
                    vitaminCMg: 14,
                    vitaminDMcg: 0,
                    magnesiumMg: 24,
                    zincMg: 0.2,
                    imageURL: nil,
                    dateCreated: Date(timeIntervalSinceNow: -86400 * 5),
                    dateModified: Date(timeIntervalSinceNow: -86400 * 2),
                    clickCount: 2
                ),
                    amount: 50,
                    unit: .grams
                )
            ],
            bookmarkCount: 30,
            favouriteCount: 10
        )
        ]
    }
}
