//
//  MealLogModel.swift
//  DialedIn
//
//  Created by AI on 13/10/2025.
//

import Foundation
import IdentifiableByString

enum MealType: String, Codable, CaseIterable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack
}

enum MealItemSourceType: String, Codable, CaseIterable, Sendable {
    case ingredient
    case recipe
}

struct MealItemModel: Identifiable, Codable, StringIdentifiable, Hashable {
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

struct MealLogModel: Identifiable, Codable, StringIdentifiable, Hashable {
    var id: String { mealId }
    let mealId: String
    let authorId: String
    /// yyyy-MM-dd for efficient per-day queries
    let dayKey: String
    let date: Date
    let mealType: MealType
    var items: [MealItemModel]
    var notes: String?
    // Stored totals for snapshot consistency and quick reads
    var totalCalories: Double
    var totalProteinGrams: Double
    var totalCarbGrams: Double
    var totalFatGrams: Double
    
    static var mock: MealLogModel {
        let today = Date()
        return MealLogModel(
            mealId: UUID().uuidString,
            authorId: "mock-user",
            dayKey: today.dayKey,
            date: today,
            mealType: .breakfast,
            items: MealItemModel.mocks,
            notes: "Had a great breakfast!",
            totalCalories: 650,
            totalProteinGrams: 35,
            totalCarbGrams: 75,
            totalFatGrams: 18
        )
    }
    
    /// Generates a week's worth of mock meal data (Monday to Sunday) for testing
    static var mockWeekMealsByDay: [String: [MealLogModel]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        
        var mockMealsByDay: [String: [MealLogModel]] = [:]
        
        for offset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: offset, to: monday) ?? monday
            let key = date.dayKey
            
            // Create sample meals with items
            let breakfastItems = [
                MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .ingredient,
                    sourceId: "ing-oats",
                    displayName: "Oatmeal",
                    amount: 50,
                    unit: "g",
                    resolvedGrams: 50,
                    resolvedMilliliters: nil,
                    calories: 190,
                    proteinGrams: 7,
                    carbGrams: 32,
                    fatGrams: 3.5
                )
            ]
            
            let breakfast = MealLogModel(
                mealId: UUID().uuidString,
                authorId: "mock-user",
                dayKey: key,
                date: date.addingTimeInterval(hours: 8),
                mealType: .breakfast,
                items: breakfastItems,
                notes: nil,
                totalCalories: breakfastItems.compactMap { $0.calories }.reduce(0, +),
                totalProteinGrams: breakfastItems.compactMap { $0.proteinGrams }.reduce(0, +),
                totalCarbGrams: breakfastItems.compactMap { $0.carbGrams }.reduce(0, +),
                totalFatGrams: breakfastItems.compactMap { $0.fatGrams }.reduce(0, +)
            )
            
            mockMealsByDay[key] = [breakfast]
        }
        
        return mockMealsByDay
    }
    
    /// Generates a week's worth of comprehensive preview meal data with breakfast, lunch, and dinner
    static var previewWeekMealsByDay: [String: [MealLogModel]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        
        var mealsByDay: [String: [MealLogModel]] = [:]
        
        for offset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: offset, to: monday) ?? monday
            let key = date.dayKey
            
            // Create sample meal items for variety
            let breakfastItems = [
                MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .ingredient,
                    sourceId: "ing-oats",
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
                    sourceId: "ing-banana",
                    displayName: "Banana",
                    amount: 1,
                    unit: "unit",
                    resolvedGrams: 120,
                    resolvedMilliliters: nil,
                    calories: 105,
                    proteinGrams: 1.3,
                    carbGrams: 27,
                    fatGrams: 0.4
                )
            ]
            
            let lunchItems = [
                MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .ingredient,
                    sourceId: "ing-chicken",
                    displayName: "Grilled Chicken",
                    amount: 200,
                    unit: "g",
                    resolvedGrams: 200,
                    resolvedMilliliters: nil,
                    calories: 330,
                    proteinGrams: 62,
                    carbGrams: 0,
                    fatGrams: 7
                ),
                MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .ingredient,
                    sourceId: "ing-rice",
                    displayName: "Brown Rice",
                    amount: 150,
                    unit: "g",
                    resolvedGrams: 150,
                    resolvedMilliliters: nil,
                    calories: 165,
                    proteinGrams: 3.5,
                    carbGrams: 35,
                    fatGrams: 1.2
                ),
                MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .ingredient,
                    sourceId: "ing-broccoli",
                    displayName: "Broccoli",
                    amount: 100,
                    unit: "g",
                    resolvedGrams: 100,
                    resolvedMilliliters: nil,
                    calories: 35,
                    proteinGrams: 2.8,
                    carbGrams: 7,
                    fatGrams: 0.4
                )
            ]
            
            let dinnerItems = [
                MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .recipe,
                    sourceId: "recipe-salmon",
                    displayName: "Baked Salmon with Vegetables",
                    amount: 1,
                    unit: "serving",
                    resolvedGrams: nil,
                    resolvedMilliliters: nil,
                    calories: 450,
                    proteinGrams: 38,
                    carbGrams: 22,
                    fatGrams: 24
                ),
                MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .ingredient,
                    sourceId: "ing-quinoa",
                    displayName: "Quinoa",
                    amount: 100,
                    unit: "g",
                    resolvedGrams: 100,
                    resolvedMilliliters: nil,
                    calories: 120,
                    proteinGrams: 4.4,
                    carbGrams: 21,
                    fatGrams: 1.9
                )
            ]
            
            let breakfast = MealLogModel(
                mealId: UUID().uuidString,
                authorId: "preview-user",
                dayKey: key,
                date: date.addingTimeInterval(hours: 8),
                mealType: .breakfast,
                items: breakfastItems,
                notes: offset % 3 == 0 ? "Great morning meal!" : nil,
                totalCalories: breakfastItems.compactMap { $0.calories }.reduce(0, +),
                totalProteinGrams: breakfastItems.compactMap { $0.proteinGrams }.reduce(0, +),
                totalCarbGrams: breakfastItems.compactMap { $0.carbGrams }.reduce(0, +),
                totalFatGrams: breakfastItems.compactMap { $0.fatGrams }.reduce(0, +)
            )
            
            let lunch = MealLogModel(
                mealId: UUID().uuidString,
                authorId: "preview-user",
                dayKey: key,
                date: date.addingTimeInterval(hours: 13),
                mealType: .lunch,
                items: lunchItems,
                notes: nil,
                totalCalories: lunchItems.compactMap { $0.calories }.reduce(0, +),
                totalProteinGrams: lunchItems.compactMap { $0.proteinGrams }.reduce(0, +),
                totalCarbGrams: lunchItems.compactMap { $0.carbGrams }.reduce(0, +),
                totalFatGrams: lunchItems.compactMap { $0.fatGrams }.reduce(0, +)
            )
            
            let dinner = MealLogModel(
                mealId: UUID().uuidString,
                authorId: "preview-user",
                dayKey: key,
                date: date.addingTimeInterval(hours: 19),
                mealType: .dinner,
                items: dinnerItems,
                notes: offset % 2 == 0 ? "Delicious dinner!" : nil,
                totalCalories: dinnerItems.compactMap { $0.calories }.reduce(0, +),
                totalProteinGrams: dinnerItems.compactMap { $0.proteinGrams }.reduce(0, +),
                totalCarbGrams: dinnerItems.compactMap { $0.carbGrams }.reduce(0, +),
                totalFatGrams: dinnerItems.compactMap { $0.fatGrams }.reduce(0, +)
            )
            
            mealsByDay[key] = [breakfast, lunch, dinner]
        }
        
        return mealsByDay
    }
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
    
    static var mocks: [MealItemModel] {
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
}
