//
//  OFFProductDTO.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import Foundation

struct OFFProductDTO: Decodable {
    let productName: String?
    let brands: String?
    let nutriments: OFFNutrimentsDTO?
    let servingSize: String?
    let servingQuantity: Double?
    let imageFrontSmallUrl: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case nutriments
        case servingSize = "serving_size"
        case servingQuantity = "serving_quantity"
        case imageFrontSmallUrl = "image_front_small_url"
        case imageUrl = "image_url"
    }

    func toFoodModel(barcode: String) -> FoodModel? {
        guard let name = productName, !name.isEmpty else { return nil }
        let now = Date()
        let nutrient = nutriments
        let parsed = servingSize.map { parseServingSize($0) }

        var nutrients: [NutrientKey: Double] = [:]
        func set(_ key: NutrientKey, _ value: Double?) {
            if let val = value { nutrients[key] = val }
        }
        set(.calories, nutrient?.energyKcal100g ?? nutrient?.energyKj100g.map { $0 / 4.184 })
        set(.protein, nutrient?.proteins100g)
        set(.carbs, nutrient?.carbohydrates100g)
        set(.fatTotal, nutrient?.fat100g)
        set(.fatSaturated, nutrient?.saturatedFat100g)
        set(.fiber, nutrient?.fiber100g)
        set(.sugar, nutrient?.sugars100g)
        set(.sodiumMg, nutrient?.sodium100g.map { $0 * 1000 })
        set(.potassiumMg, nutrient?.potassium100g)
        set(.calciumMg, nutrient?.calcium100g)
        set(.ironMg, nutrient?.iron100g)
        set(.vitaminAMcg, nutrient?.vitaminA100g)
        set(.vitaminB6Mg, nutrient?.vitaminB6100g)
        set(.vitaminB12Mcg, nutrient?.vitaminB12100g)
        set(.vitaminCMg, nutrient?.vitaminC100g)
        set(.vitaminDMcg, nutrient?.vitaminD100g)
        set(.vitaminEMg, nutrient?.vitaminE100g)
        set(.vitaminKMcg, nutrient?.vitaminK100g)
        set(.magnesiumMg, nutrient?.magnesium100g)
        set(.zincMg, nutrient?.zinc100g)
        set(.biotinMcg, nutrient?.biotin100g)
        set(.copperMg, nutrient?.copper100g)
        set(.folateMcg, nutrient?.folates100g)
        set(.iodineMcg, nutrient?.iodine100g)
        set(.niacinMg, nutrient?.niacin100g)
        set(.thiaminMg, nutrient?.thiamin100g)
        set(.caffeineMg, nutrient?.caffeine100g)
        set(.chlorideMg, nutrient?.chloride100g)
        set(.seleniumMcg, nutrient?.selenium100g)
        set(.manganeseMg, nutrient?.manganese100g)
        set(.phosphorusMg, nutrient?.phosphorus100g)
        set(.riboflavinMg, nutrient?.riboflavin100g)
        set(.cholesterolMg, nutrient?.cholesterol100g)
        set(.pantothenicAcidMg, nutrient?.pantothenicAcid100g)

        return FoodModel(
            ingredientId: UUID().uuidString,
            authorId: nil,
            name: name,
            brandName: brands,
            measurementMethod: .weight,
            nutrients: nutrients,
            barcode: barcode,
            servingWeight: servingQuantity,
            portionSize: parsed?.portionSize,
            portionName: parsed?.portionName,
            imageURL: imageFrontSmallUrl ?? imageUrl,
            dateCreated: now,
            dateModified: now
        )
    }
}
