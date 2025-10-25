//
//  IngredientTemplateModelInitializationTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Testing
import Foundation

struct IngredientTemplateInitTests {

    // MARK: - Initialization Tests
    
    @Test("Test Basic Initialization")
    func testBasicInitialization() {
        let randomIngredientId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let ingredient = IngredientTemplateModel(
            ingredientId: randomIngredientId,
            name: randomName,
            calories: 100.0,
            protein: 10.0,
            carbs: 50.0,
            fatTotal: 5.0,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(ingredient.ingredientId == randomIngredientId)
        #expect(ingredient.name == randomName)
        #expect(ingredient.calories == 100.0)
        #expect(ingredient.protein == 10.0)
        #expect(ingredient.carbs == 50.0)
        #expect(ingredient.fatTotal == 5.0)
    }
    
    @Test("Test Initialization With Essential Properties")
    func testInitializationWithEssentialProperties() {
        let randomIngredientId = String.random
        let randomAuthorId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let ingredient = IngredientTemplateModel(
            ingredientId: randomIngredientId,
            authorId: randomAuthorId,
            name: randomName,
            calories: 250.0,
            protein: 15.0,
            carbs: 30.0,
            fatTotal: 8.0,
            fiber: 5.0,
            sugar: 10.0,
            imageURL: "https://example.com/image.jpg",
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 10,
            bookmarkCount: 5,
            favouriteCount: 2
        )
        
        #expect(ingredient.ingredientId == randomIngredientId)
        #expect(ingredient.authorId == randomAuthorId)
        #expect(ingredient.name == randomName)
        #expect(ingredient.calories == 250.0)
        #expect(ingredient.protein == 15.0)
        #expect(ingredient.clickCount == 10)
        #expect(ingredient.bookmarkCount == 5)
        #expect(ingredient.favouriteCount == 2)
    }
    
    @Test("Test Initialization With Nil Optional Values")
    func testInitializationWithNilOptionalValues() {
        let randomIngredientId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let ingredient = IngredientTemplateModel(
            ingredientId: randomIngredientId,
            authorId: nil,
            name: randomName,
            description: nil,
            calories: 100.0,
            protein: 10.0,
            carbs: 50.0,
            fatTotal: 5.0,
            fatSaturated: nil,
            fatMonounsaturated: nil,
            fatPolyunsaturated: nil,
            fiber: nil,
            sugar: nil,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: nil,
            bookmarkCount: nil,
            favouriteCount: nil
        )
        
        #expect(ingredient.authorId == nil)
        #expect(ingredient.description == nil)
        #expect(ingredient.fatSaturated == nil)
        #expect(ingredient.fiber == nil)
        #expect(ingredient.sugar == nil)
        #expect(ingredient.clickCount == nil)
        #expect(ingredient.bookmarkCount == nil)
        #expect(ingredient.favouriteCount == nil)
    }
    
    @Test("Test Initialization With Different Measurement Methods")
    func testInitializationWithDifferentMeasurementMethods() {
        let randomIngredientId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let weightIngredient = IngredientTemplateModel(
            ingredientId: randomIngredientId,
            name: randomName,
            measurementMethod: .weight,
            calories: 100.0,
            protein: 10.0,
            carbs: 50.0,
            fatTotal: 5.0,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let volumeIngredient = IngredientTemplateModel(
            ingredientId: String.random,
            name: randomName,
            measurementMethod: .volume,
            calories: 100.0,
            protein: 10.0,
            carbs: 50.0,
            fatTotal: 5.0,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(weightIngredient.measurementMethod == .weight)
        #expect(volumeIngredient.measurementMethod == .volume)
    }
}
