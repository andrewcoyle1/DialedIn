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

struct RecipeIngredientModel: Identifiable, Codable, Hashable {
    var id: String { ingredient.ingredientId }
    let ingredient: IngredientTemplateModel
    var amount: Double
    var unit: IngredientAmountUnit
    
    init(ingredient: IngredientTemplateModel, amount: Double, unit: IngredientAmountUnit? = nil) {
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
    static var mocks: [RecipeIngredientModel] {
        Array(IngredientTemplateModel.mocks.prefix(10)).map { RecipeIngredientModel(ingredient: $0, amount: 1) }
    }
}
