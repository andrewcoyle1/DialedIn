//
//  IngredientTemplateModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation
import IdentifiableByString

struct IngredientTemplateModel: Identifiable, Codable, StringIdentifiable, Hashable {
    var id: String {
        ingredientId
    }
    
    let ingredientId: String
    let authorId: String?
    let name: String
    let description: String?
    let measurementMethod: MeasurementMethod
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    let fiber: Double?
    let sugar: Double?
    // let macronutrients: Macronutrients
    let sodiumMg: Double?
    let potassiumMg: Double?
    let calciumMg: Double?
    let ironMg: Double?
    let vitaminCMg: Double?
    let vitaminDMcg: Double?
    let magnesiumMg: Double?
    let zincMg: Double?
    // let micronutrients: Micronutrients
    private(set) var imageURL: String?
    let dateCreated: Date
    let dateModified: Date
    let clickCount: Int?
    let bookmarkCount: Int?
    let favouriteCount: Int?
    
    init(
        ingredientId: String,
        authorId: String? = nil,
        name: String,
        description: String? = nil,
        measurementMethod: MeasurementMethod = .weight,
        calories: Double?,
        protein: Double?,
        carbs: Double?,
        fat: Double?,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodiumMg: Double? = nil,
        potassiumMg: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        vitaminCMg: Double? = nil,
        vitaminDMcg: Double? = nil,
        magnesiumMg: Double? = nil,
        zincMg: Double? = nil,
        imageURL: String? = nil,
        dateCreated: Date,
        dateModified: Date,
        clickCount: Int? = nil,
        bookmarkCount: Int? = nil,
        favouriteCount: Int? = nil
    ) {
        self.ingredientId = ingredientId
        self.authorId = authorId
        self.name = name
        self.description = description
        self.measurementMethod = measurementMethod
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodiumMg = sodiumMg
        self.potassiumMg = potassiumMg
        self.calciumMg = calciumMg
        self.ironMg = ironMg
        self.vitaminCMg = vitaminCMg
        self.vitaminDMcg = vitaminDMcg
        self.magnesiumMg = magnesiumMg
        self.zincMg = zincMg
        self.imageURL = imageURL
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.clickCount = clickCount
        self.bookmarkCount = bookmarkCount
        self.favouriteCount = favouriteCount
    }
    
    mutating func updateImageURL(imageUrl: String) {
        self.imageURL = imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case ingredientId = "ingredient_id"
        case authorId = "author_id"
        case name
        case description
        case measurementMethod = "measurement_method"
        case calories = "calories"
        case protein = "protein"
        case carbs = "carbs"
        case fat = "fat"
        case fiber = "fiber"
        case sugar = "sugar"
        case sodiumMg = "sodium_mg"
        case potassiumMg = "potassium_mg"
        case calciumMg = "calcium_mg"
        case ironMg = "iron_mg"
        case vitaminCMg = "vitamin_c_mg"
        case vitaminDMcg = "vitamin_d_mcg"
        case magnesiumMg = "magnesium_mg"
        case zincMg = "zinc_mg"
        case imageURL = "image_url"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case clickCount = "click_count"
        case bookmarkCount = "bookmark_count"
        case favouriteCount = "favourite_count"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.ingredientId.rawValue)": ingredientId,
            "user_\(CodingKeys.authorId.rawValue)": authorId,
            "user_\(CodingKeys.name.rawValue)": name,
            "user_\(CodingKeys.description.rawValue)": description,
            "user_\(CodingKeys.measurementMethod.rawValue)": measurementMethod.rawValue,
            "user_\(CodingKeys.calories.rawValue)": calories,
            "user_\(CodingKeys.protein.rawValue)": protein,
            "user_\(CodingKeys.carbs.rawValue)": carbs,
            "user_\(CodingKeys.fat.rawValue)": fat,
            "user_\(CodingKeys.fiber.rawValue)": fiber,
            "user_\(CodingKeys.sugar.rawValue)": sugar,
            "user_\(CodingKeys.sodiumMg.rawValue)": sodiumMg,
            "user_\(CodingKeys.potassiumMg.rawValue)": potassiumMg,
            "user_\(CodingKeys.calciumMg.rawValue)": calciumMg,
            "user_\(CodingKeys.ironMg.rawValue)": ironMg,
            "user_\(CodingKeys.vitaminCMg.rawValue)": vitaminCMg,
            "user_\(CodingKeys.vitaminDMcg.rawValue)": vitaminDMcg,
            "user_\(CodingKeys.magnesiumMg.rawValue)": magnesiumMg,
            "user_\(CodingKeys.zincMg.rawValue)": zincMg,
            "user_\(CodingKeys.imageURL.rawValue)": imageURL,
            "user_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "user_\(CodingKeys.dateModified.rawValue)": dateModified,
            "user_\(CodingKeys.clickCount.rawValue)": clickCount,
            "user_\(CodingKeys.bookmarkCount.rawValue)": bookmarkCount,
            "user_\(CodingKeys.favouriteCount.rawValue)": favouriteCount
        ]
        return dict.compactMapValues({ $0 })
    }
    
    static func newIngredientTemplate(
        name: String,
        authorId: String,
        description: String? = nil,
        measurementMethod: MeasurementMethod = .weight,
        calories: Double?,
        protein: Double?,
        carbs: Double?,
        fat: Double?,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodiumMg: Double? = nil,
        potassiumMg: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        vitaminCMg: Double? = nil,
        vitaminDMcg: Double? = nil,
        magnesiumMg: Double? = nil,
        zincMg: Double? = nil,
    ) -> Self {
        IngredientTemplateModel(
            ingredientId: UUID().uuidString,
            authorId: authorId,
            name: name,
            description: description,
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
            imageURL: nil,
            dateCreated: .now,
            dateModified: .now,
            clickCount: 0,
            bookmarkCount: 0,
            favouriteCount: 0
        )
    }
    
    static var mock: IngredientTemplateModel {
        mocks[0]
    }
    
    static var mocks: [IngredientTemplateModel] {
        [
            IngredientTemplateModel(
                ingredientId: "ing-1",
                authorId: "1",
                name: "Rolled Oats",
                description: "Whole grain oats.",
                measurementMethod: .weight,
                calories: 389,
                protein: 16.9,
                carbs: 66.3,
                fat: 6.9,
                fiber: 10.6,
                sugar: 0.0,
                sodiumMg: 2,
                potassiumMg: 429,
                calciumMg: 54,
                ironMg: 4.7,
                vitaminCMg: 0.0,
                vitaminDMcg: 0.0,
                magnesiumMg: 0.0,
                zincMg: 0.0,
                imageURL: Constants.randomImage,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 12,
                bookmarkCount: 3,
                favouriteCount: 1
            ),
            IngredientTemplateModel(
                ingredientId: "ing-2",
                authorId: "2",
                name: "Whole Milk",
                description: "Dairy, 3.25% fat.",
                measurementMethod: .volume,
                calories: 61,
                protein: 3.2,
                carbs: 4.8,
                fat: 3.3,
                fiber: nil,
                sugar: 5.1,
                sodiumMg: 43,
                potassiumMg: 150,
                calciumMg: 113,
                ironMg: 0.0,
                vitaminCMg: 0.0,
                vitaminDMcg: 0.0,
                magnesiumMg: 0.0,
                zincMg: 0.0,
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 5,
                bookmarkCount: 1,
                favouriteCount: 0
            )
        ]
    }
}
