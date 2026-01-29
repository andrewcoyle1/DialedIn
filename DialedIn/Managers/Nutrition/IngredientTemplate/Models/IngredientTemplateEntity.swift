//
//  IngredientTemplateEntity.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import SwiftData

@Model
class IngredientTemplateEntity {
    @Attribute(.unique) var ingredientTemplateId: String
    var authorId: String?
    var name: String
    var ingredientDescription: String?
    var measurementMethod: MeasurementMethod

    // MARK: Macronutrients
    var calories: Double?
    var protein: Double?
    var carbs: Double?
    var fatTotal: Double?
    var fatSaturated: Double?
    var fatMonounsaturated: Double?
    var fatPolyunsaturated: Double?
    var fiber: Double?
    var sugar: Double?

    // MARK: Micronutrients (all units per 100g edible portion unless otherwise specified)
    /// Sodium (mg)
    var sodiumMg: Double?
    /// Potassium (mg)
    var potassiumMg: Double?
    /// Calcium (mg)
    var calciumMg: Double?
    /// Iron (mg)
    var ironMg: Double?
    /// Vitamin A (mcg RAE)
    var vitaminAMcg: Double?
    /// Vitamin B6 (mg)
    var vitaminB6Mg: Double?
    /// Vitamin B12 (mcg)
    var vitaminB12Mcg: Double?
    /// Vitamin C (mg)
    var vitaminCMg: Double?
    /// Vitamin D (mcg)
    var vitaminDMcg: Double?
    /// Vitamin E (mg alpha-tocopherol)
    var vitaminEMg: Double?
    /// Vitamin K (mcg)
    var vitaminKMcg: Double?
    /// Magnesium (mg)
    var magnesiumMg: Double?
    /// Zinc (mg)
    var zincMg: Double?
    /// Biotin (mcg)
    var biotinMcg: Double?
    /// Copper (mg)
    var copperMg: Double?
    /// Folate (mcg DFE)
    var folateMcg: Double?
    /// Iodine (mcg)
    var iodineMcg: Double?
    /// Niacin (mg NE)
    var niacinMg: Double?
    /// Thiamin (mg)
    var thiaminMg: Double?
    /// Caffeine (mg)
    var caffeineMg: Double?
    /// Chloride (mg)
    var chlorideMg: Double?
    /// Chromium (mcg)
    var chromiumMcg: Double?
    /// Selenium (mcg)
    var seleniumMcg: Double?
    /// Manganese (mg)
    var manganeseMg: Double?
    /// Molybdenum (mcg)
    var molybdenumMcg: Double?
    /// Phosphorus (mg)
    var phosphorusMg: Double?
    /// Riboflavin (mg)
    var riboflavinMg: Double?
    /// Cholesterol (mg)
    var cholesterolMg: Double?
    /// Pantothenic Acid (mg)
    var pantothenicAcidMg: Double?

    var imageURL: String?
    var dateCreated: Date
    var dateModified: Date
    var clickCount: Int?
    var bookmarkCount: Int?
    var favouriteCount: Int?
    
    init(from model: IngredientTemplateModel) {
        self.ingredientTemplateId = model.ingredientId
        self.authorId = model.authorId
        self.name = model.name
        self.ingredientDescription = model.description
        self.measurementMethod = model.measurementMethod
        self.calories = model.calories
        self.protein = model.protein
        self.carbs = model.carbs
        self.fatTotal = model.fatTotal
        self.fatSaturated = model.fatSaturated
        self.fatMonounsaturated = model.fatMonounsaturated
        self.fatPolyunsaturated = model.fatPolyunsaturated
        self.fiber = model.fiber
        self.sugar = model.sugar
        self.sodiumMg = model.sodiumMg
        self.potassiumMg = model.potassiumMg
        self.calciumMg = model.calciumMg
        self.ironMg = model.ironMg
        self.vitaminAMcg = model.vitaminAMcg
        self.vitaminB6Mg = model.vitaminB6Mg
        self.vitaminB12Mcg = model.vitaminB12Mcg
        self.vitaminCMg = model.vitaminCMg
        self.vitaminDMcg = model.vitaminDMcg
        self.vitaminEMg = model.vitaminEMg
        self.vitaminKMcg = model.vitaminKMcg
        self.magnesiumMg = model.magnesiumMg
        self.zincMg = model.zincMg
        self.biotinMcg = model.biotinMcg
        self.copperMg = model.copperMg
        self.folateMcg = model.folateMcg
        self.iodineMcg = model.iodineMcg
        self.niacinMg = model.niacinMg
        self.thiaminMg = model.thiaminMg
        self.caffeineMg = model.caffeineMg
        self.chlorideMg = model.chlorideMg
        self.chromiumMcg = model.chromiumMcg
        self.seleniumMcg = model.seleniumMcg
        self.manganeseMg = model.manganeseMg
        self.molybdenumMcg = model.molybdenumMcg
        self.phosphorusMg = model.phosphorusMg
        self.riboflavinMg = model.riboflavinMg
        self.cholesterolMg = model.cholesterolMg
        self.pantothenicAcidMg = model.pantothenicAcidMg
        self.imageURL = model.imageURL
        self.dateCreated = model.dateCreated
        self.dateModified = model.dateModified
        self.clickCount = model.clickCount
        self.bookmarkCount = model.bookmarkCount
        self.favouriteCount = model.favouriteCount
    }
    
    @MainActor
    func toModel() -> IngredientTemplateModel {
        IngredientTemplateModel(
            ingredientId: ingredientTemplateId, authorId: authorId,
            name: name, description: ingredientDescription,
            measurementMethod: measurementMethod, calories: calories,
            protein: protein, carbs: carbs, fatTotal: fatTotal,
            fatSaturated: fatSaturated, fatMonounsaturated: fatMonounsaturated,
            fatPolyunsaturated: fatPolyunsaturated, fiber: fiber, sugar: sugar,
            sodiumMg: sodiumMg, potassiumMg: potassiumMg, calciumMg: calciumMg,
            ironMg: ironMg, vitaminAMcg: vitaminAMcg, vitaminB6Mg: vitaminB6Mg,
            vitaminB12Mcg: vitaminB12Mcg, vitaminCMg: vitaminCMg,
            vitaminDMcg: vitaminDMcg, vitaminEMg: vitaminEMg,
            vitaminKMcg: vitaminKMcg, magnesiumMg: magnesiumMg, zincMg: zincMg,
            biotinMcg: biotinMcg, copperMg: copperMg, folateMcg: folateMcg,
            iodineMcg: iodineMcg, niacinMg: niacinMg, thiaminMg: thiaminMg,
            caffeineMg: caffeineMg, chlorideMg: chlorideMg,
            chromiumMcg: chromiumMcg, seleniumMcg: seleniumMcg,
            manganeseMg: manganeseMg, molybdenumMcg: molybdenumMcg,
            phosphorusMg: phosphorusMg, riboflavinMg: riboflavinMg,
            cholesterolMg: cholesterolMg, pantothenicAcidMg: pantothenicAcidMg,
            imageURL: imageURL, dateCreated: dateCreated,
            dateModified: dateModified, clickCount: clickCount,
            bookmarkCount: bookmarkCount, favouriteCount: favouriteCount
        )
    }
}
