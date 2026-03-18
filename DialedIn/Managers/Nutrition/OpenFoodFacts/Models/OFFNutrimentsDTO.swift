//
//  OFFNutrimentsDTO.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import Foundation

struct OFFNutrimentsDTO: Decodable {
    let energyKcal100g: Double?
    let energyKj100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let saturatedFat100g: Double?
    let fiber100g: Double?
    let sugars100g: Double?
    let sodium100g: Double?
    let potassium100g: Double?
    let calcium100g: Double?
    let iron100g: Double?
    let vitaminA100g: Double?
    let vitaminB6100g: Double?
    let vitaminB12100g: Double?
    let vitaminC100g: Double?
    let vitaminD100g: Double?
    let vitaminE100g: Double?
    let vitaminK100g: Double?
    let magnesium100g: Double?
    let zinc100g: Double?
    let phosphorus100g: Double?
    let cholesterol100g: Double?
    let caffeine100g: Double?
    let riboflavin100g: Double?
    let thiamin100g: Double?
    let niacin100g: Double?
    let biotin100g: Double?
    let folates100g: Double?
    let iodine100g: Double?
    let selenium100g: Double?
    let manganese100g: Double?
    let copper100g: Double?
    let chloride100g: Double?
    let pantothenicAcid100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case energyKj100g = "energy_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case saturatedFat100g = "saturated-fat_100g"
        case fiber100g = "fiber_100g"
        case sugars100g = "sugars_100g"
        case sodium100g = "sodium_100g"
        case potassium100g = "potassium_100g"
        case calcium100g = "calcium_100g"
        case iron100g = "iron_100g"
        case vitaminA100g = "vitamin-a_100g"
        case vitaminB6100g = "vitamin-b6_100g"
        case vitaminB12100g = "vitamin-b12_100g"
        case vitaminC100g = "vitamin-c_100g"
        case vitaminD100g = "vitamin-d_100g"
        case vitaminE100g = "vitamin-e_100g"
        case vitaminK100g = "vitamin-k_100g"
        case magnesium100g = "magnesium_100g"
        case zinc100g = "zinc_100g"
        case phosphorus100g = "phosphorus_100g"
        case cholesterol100g = "cholesterol_100g"
        case caffeine100g = "caffeine_100g"
        case riboflavin100g = "riboflavin_100g"
        case thiamin100g = "thiamin_100g"
        case niacin100g = "niacin_100g"
        case biotin100g = "biotin_100g"
        case folates100g = "folates_100g"
        case iodine100g = "iodine_100g"
        case selenium100g = "selenium_100g"
        case manganese100g = "manganese_100g"
        case copper100g = "copper_100g"
        case chloride100g = "chloride_100g"
        case pantothenicAcid100g = "pantothenic-acid_100g"
    }
}
