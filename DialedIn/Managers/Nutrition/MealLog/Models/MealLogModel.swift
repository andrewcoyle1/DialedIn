//
//  MealLogModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import Foundation

struct MealLogModel: DataSyncModelProtocol, Hashable {
    var id: String { mealId }
    let mealId: String
    let authorId: String
    /// yyyy-MM-dd for efficient per-day queries
    let dayKey: String
    let date: Date
    var items: [MealItemModel]
    var notes: String?

    var totalCalories: Double { items.compactMap { $0.nutrients[.calories] }.reduce(0, +) }
    var totalProteinGrams: Double { items.compactMap { $0.nutrients[.protein] }.reduce(0, +) }
    var totalCarbGrams: Double { items.compactMap { $0.nutrients[.carbs] }.reduce(0, +) }
    var totalFatGrams: Double { items.compactMap { $0.nutrients[.fatTotal] }.reduce(0, +) }

    init(
        mealId: String = UUID().uuidString,
        authorId: String,
        dayKey: String,
        date: Date,
        items: [MealItemModel],
        notes: String? = nil
    ) {
        self.mealId = mealId
        self.authorId = authorId
        self.dayKey = dayKey
        self.date = date
        self.items = items
        self.notes = notes
    }

    enum CodingKeys: String, CodingKey {
        case mealId = "meal_id"
        case authorId = "author_id"
        case dayKey = "day_key"
        case date
        case items
        case notes
    }
}
