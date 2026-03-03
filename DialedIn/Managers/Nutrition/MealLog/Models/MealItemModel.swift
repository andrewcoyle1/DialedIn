//
//  MealItemModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/03/2026.
//

import Foundation

struct MealItemModel: DataSyncModelProtocol, Hashable {
    var id: String { itemId }
    let itemId: String
    let sourceType: MealItemSourceType
    let sourceId: String
    let displayName: String
    // Measurement entered by user
    let amount: Double
    let unit: String // e.g., "g", "ml", "serving"
    // Resolved standardized amounts for nutrition calculations when available
    let resolvedGrams: Double?
    let resolvedMilliliters: Double?
    // Snapshot of nutrition at time of logging
    let calories: Double?
    let proteinGrams: Double?
    let carbGrams: Double?
    let fatGrams: Double?
}

extension MealItemModel {
    static var mock: MealItemModel {
        MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: "ingredient-123",
            displayName: "Chicken Breast",
            amount: 200,
            unit: "g",
            resolvedGrams: 200,
            resolvedMilliliters: nil,
            calories: 330,
            proteinGrams: 62,
            carbGrams: 0,
            fatGrams: 7
        )
    }
    
    static let mocks: [MealItemModel] =
    [
        MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: "ing-1",
            displayName: "Oatmeal",
            amount: 50,
            unit: "g",
            resolvedGrams: 50,
            resolvedMilliliters: nil,
            calories: 190,
            proteinGrams: 7,
            carbGrams: 32,
            fatGrams: 3.5
        ),
        MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: "ing-2",
            displayName: "Banana",
            amount: 1,
            unit: "unit",
            resolvedGrams: 120,
            resolvedMilliliters: nil,
            calories: 105,
            proteinGrams: 1.3,
            carbGrams: 27,
            fatGrams: 0.4
        ),
        MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: "ing-3",
            displayName: "Almond Butter",
            amount: 20,
            unit: "g",
            resolvedGrams: 20,
            resolvedMilliliters: nil,
            calories: 120,
            proteinGrams: 4,
            carbGrams: 4,
            fatGrams: 10
        ),
        MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .ingredient,
            sourceId: "ing-4",
            displayName: "Greek Yogurt",
            amount: 150,
            unit: "g",
            resolvedGrams: 150,
            resolvedMilliliters: nil,
            calories: 135,
            proteinGrams: 18,
            carbGrams: 8,
            fatGrams: 3.5
        ),
        MealItemModel(
            itemId: UUID().uuidString,
            sourceType: .recipe,
            sourceId: "recipe-1",
            displayName: "Protein Smoothie",
            amount: 1,
            unit: "serving",
            resolvedGrams: nil,
            resolvedMilliliters: 350,
            calories: 280,
            proteinGrams: 32,
            carbGrams: 25,
            fatGrams: 8
        )
    ]
}
