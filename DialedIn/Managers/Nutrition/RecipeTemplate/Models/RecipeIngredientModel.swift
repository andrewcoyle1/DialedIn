//
//  RecipeIngredientModel.swift
//  DialedIn
//
//  Wrapper for an ingredient within a recipe, including amount and unit.
//

import Foundation

enum IngredientAmountUnit: String, Codable, CaseIterable, Sendable {
    case grams
    case milliliters
    case units
}

struct RecipeIngredientModel: DataSyncModelProtocol {
    var id: String { ingredient.ingredientId }
    var name: String { ingredient.name }
    var description: String? { ingredient.description }
    var imageURL: String? { ingredient.imageURL }
    let ingredient: FoodModel
    var amount: Double
    var unit: IngredientAmountUnit
    
    init(ingredient: FoodModel, amount: Double, unit: IngredientAmountUnit? = nil) {
        self.ingredient = ingredient
        self.amount = amount
        if let unit = unit {
            self.unit = unit
        } else {
            switch ingredient.measurementMethod {
            case .weight:
                self.unit = .grams
            case .volume:
                self.unit = .milliliters
            }
        }
    }
    static var mock: RecipeIngredientModel {
        mocks[0]
    }
    static let mocks: [RecipeIngredientModel] = Array(FoodModel.mocks.prefix(10)).map { RecipeIngredientModel(ingredient: $0, amount: 1) }
}
