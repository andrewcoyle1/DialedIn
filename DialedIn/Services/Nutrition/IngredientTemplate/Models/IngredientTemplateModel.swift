//
//  IngredientTemplateModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import Foundation

struct IngredientTemplateModel: Identifiable, Codable, Hashable {
    var id: String {
        ingredientId
    }
    
    let ingredientId: String
    let authorId: String?
    let name: String
    let description: String?
    let measurementMethod: MeasurementMethod

    // MARK: Macronutrients
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fatTotal: Double?
    let fatSaturated: Double?
    let fatMonounsaturated: Double?
    let fatPolyunsaturated: Double?
    let fiber: Double?
    let sugar: Double?

    // MARK: Micronutrients (all units per 100g edible portion unless otherwise specified)
    /// Sodium (mg)
    let sodiumMg: Double?
    /// Potassium (mg)
    let potassiumMg: Double?
    /// Calcium (mg)
    let calciumMg: Double?
    /// Iron (mg)
    let ironMg: Double?
    /// Vitamin A (mcg RAE)
    let vitaminAMcg: Double?
    /// Vitamin B6 (mg)
    let vitaminB6Mg: Double?
    /// Vitamin B12 (mcg)
    let vitaminB12Mcg: Double?
    /// Vitamin C (mg)
    let vitaminCMg: Double?
    /// Vitamin D (mcg)
    let vitaminDMcg: Double?
    /// Vitamin E (mg alpha-tocopherol)
    let vitaminEMg: Double?
    /// Vitamin K (mcg)
    let vitaminKMcg: Double?
    /// Magnesium (mg)
    let magnesiumMg: Double?
    /// Zinc (mg)
    let zincMg: Double?
    /// Biotin (mcg)
    let biotinMcg: Double?
    /// Copper (mg)
    let copperMg: Double?
    /// Folate (mcg DFE)
    let folateMcg: Double?
    /// Iodine (mcg)
    let iodineMcg: Double?
    /// Niacin (mg NE)
    let niacinMg: Double?
    /// Thiamin (mg)
    let thiaminMg: Double?
    /// Caffeine (mg)
    let caffeineMg: Double?
    /// Chloride (mg)
    let chlorideMg: Double?
    /// Chromium (mcg)
    let chromiumMcg: Double?
    /// Selenium (mcg)
    let seleniumMcg: Double?
    /// Manganese (mg)
    let manganeseMg: Double?
    /// Molybdenum (mcg)
    let molybdenumMcg: Double?
    /// Phosphorus (mg)
    let phosphorusMg: Double?
    /// Riboflavin (mg)
    let riboflavinMg: Double?
    /// Cholesterol (mg)
    let cholesterolMg: Double?
    /// Pantothenic Acid (mg)
    let pantothenicAcidMg: Double?

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
        fatTotal: Double?,
        fatSaturated: Double? = nil,
        fatMonounsaturated: Double? = nil,
        fatPolyunsaturated: Double? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodiumMg: Double? = nil,
        potassiumMg: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        vitaminAMcg: Double? = nil,
        vitaminB6Mg: Double? = nil,
        vitaminB12Mcg: Double? = nil,
        vitaminCMg: Double? = nil,
        vitaminDMcg: Double? = nil,
        vitaminEMg: Double? = nil,
        vitaminKMcg: Double? = nil,
        magnesiumMg: Double? = nil,
        zincMg: Double? = nil,
        biotinMcg: Double? = nil,
        copperMg: Double? = nil,
        folateMcg: Double? = nil,
        iodineMcg: Double? = nil,
        niacinMg: Double? = nil,
        thiaminMg: Double? = nil,
        caffeineMg: Double? = nil,
        chlorideMg: Double? = nil,
        chromiumMcg: Double? = nil,
        seleniumMcg: Double? = nil,
        manganeseMg: Double? = nil,
        molybdenumMcg: Double? = nil,
        phosphorusMg: Double? = nil,
        riboflavinMg: Double? = nil,
        cholesterolMg: Double? = nil,
        pantothenicAcidMg: Double? = nil,
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
        self.fatTotal = fatTotal
        self.fatSaturated = fatSaturated
        self.fatMonounsaturated = fatMonounsaturated
        self.fatPolyunsaturated = fatPolyunsaturated
        self.fiber = fiber
        self.sugar = sugar
        self.sodiumMg = sodiumMg
        self.potassiumMg = potassiumMg
        self.calciumMg = calciumMg
        self.ironMg = ironMg
        self.vitaminAMcg = vitaminAMcg
        self.vitaminB6Mg = vitaminB6Mg
        self.vitaminB12Mcg = vitaminB12Mcg
        self.vitaminCMg = vitaminCMg
        self.vitaminDMcg = vitaminDMcg
        self.vitaminEMg = vitaminEMg
        self.vitaminKMcg = vitaminKMcg
        self.magnesiumMg = magnesiumMg
        self.zincMg = zincMg
        self.biotinMcg = biotinMcg
        self.copperMg = copperMg
        self.folateMcg = folateMcg
        self.iodineMcg = iodineMcg
        self.niacinMg = niacinMg
        self.thiaminMg = thiaminMg
        self.caffeineMg = caffeineMg
        self.chlorideMg = chlorideMg
        self.chromiumMcg = chromiumMcg
        self.seleniumMcg = seleniumMcg
        self.manganeseMg = manganeseMg
        self.molybdenumMcg = molybdenumMcg
        self.phosphorusMg = phosphorusMg
        self.riboflavinMg = riboflavinMg
        self.cholesterolMg = cholesterolMg
        self.pantothenicAcidMg = pantothenicAcidMg
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
        case calories
        case protein
        case carbs
        case fatTotal = "fat_total"
        case fatSaturated = "fat_saturated"
        case fatMonounsaturated = "fat_monounsaturated"
        case fatPolyunsaturated = "fat_polyunsaturated"
        case fiber
        case sugar
        case sodiumMg = "sodium_mg"
        case potassiumMg = "potassium_mg"
        case calciumMg = "calcium_mg"
        case ironMg = "iron_mg"
        case vitaminAMcg = "vitamin_a_mcg"
        case vitaminB6Mg = "vitamin_b6_mg"
        case vitaminB12Mcg = "vitamin_b12_mcg"
        case vitaminCMg = "vitamin_c_mg"
        case vitaminDMcg = "vitamin_d_mcg"
        case vitaminEMg = "vitamin_e_mg"
        case vitaminKMcg = "vitamin_k_mcg"
        case magnesiumMg = "magnesium_mg"
        case zincMg = "zinc_mg"
        case biotinMcg = "biotin_mcg"
        case copperMg = "copper_mg"
        case folateMcg = "folate_mcg"
        case iodineMcg = "iodine_mcg"
        case niacinMg = "niacin_mg"
        case thiaminMg = "thiamin_mg"
        case caffeineMg = "caffeine_mg"
        case chlorideMg = "chloride_mg"
        case chromiumMcg = "chromium_mcg"
        case seleniumMcg = "selenium_mcg"
        case manganeseMg = "manganese_mg"
        case molybdenumMcg = "molybdenum_mcg"
        case phosphorusMg = "phosphorus_mg"
        case riboflavinMg = "riboflavin_mg"
        case cholesterolMg = "cholesterol_mg"
        case pantothenicAcidMg = "pantothenic_acid_mg"
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
            "user_\(CodingKeys.fatTotal.rawValue)": fatTotal,
            "user_\(CodingKeys.fatSaturated.rawValue)": fatSaturated,
            "user_\(CodingKeys.fatMonounsaturated.rawValue)": fatMonounsaturated,
            "user_\(CodingKeys.fatPolyunsaturated.rawValue)": fatPolyunsaturated,
            "user_\(CodingKeys.fiber.rawValue)": fiber,
            "user_\(CodingKeys.sugar.rawValue)": sugar,
            "user_\(CodingKeys.sodiumMg.rawValue)": sodiumMg,
            "user_\(CodingKeys.potassiumMg.rawValue)": potassiumMg,
            "user_\(CodingKeys.calciumMg.rawValue)": calciumMg,
            "user_\(CodingKeys.ironMg.rawValue)": ironMg,
            "user_\(CodingKeys.vitaminAMcg.rawValue)": vitaminAMcg,
            "user_\(CodingKeys.vitaminB6Mg.rawValue)": vitaminB6Mg,
            "user_\(CodingKeys.vitaminB12Mcg.rawValue)": vitaminB12Mcg,
            "user_\(CodingKeys.vitaminCMg.rawValue)": vitaminCMg,
            "user_\(CodingKeys.vitaminDMcg.rawValue)": vitaminDMcg,
            "user_\(CodingKeys.vitaminEMg.rawValue)": vitaminEMg,
            "user_\(CodingKeys.vitaminKMcg.rawValue)": vitaminKMcg,
            "user_\(CodingKeys.magnesiumMg.rawValue)": magnesiumMg,
            "user_\(CodingKeys.zincMg.rawValue)": zincMg,
            "user_\(CodingKeys.biotinMcg.rawValue)": biotinMcg,
            "user_\(CodingKeys.copperMg.rawValue)": copperMg,
            "user_\(CodingKeys.folateMcg.rawValue)": folateMcg,
            "user_\(CodingKeys.iodineMcg.rawValue)": iodineMcg,
            "user_\(CodingKeys.niacinMg.rawValue)": niacinMg,
            "user_\(CodingKeys.thiaminMg.rawValue)": thiaminMg,
            "user_\(CodingKeys.caffeineMg.rawValue)": caffeineMg,
            "user_\(CodingKeys.chlorideMg.rawValue)": chlorideMg,
            "user_\(CodingKeys.chromiumMcg.rawValue)": chromiumMcg,
            "user_\(CodingKeys.seleniumMcg.rawValue)": seleniumMcg,
            "user_\(CodingKeys.manganeseMg.rawValue)": manganeseMg,
            "user_\(CodingKeys.molybdenumMcg.rawValue)": molybdenumMcg,
            "user_\(CodingKeys.phosphorusMg.rawValue)": phosphorusMg,
            "user_\(CodingKeys.riboflavinMg.rawValue)": riboflavinMg,
            "user_\(CodingKeys.cholesterolMg.rawValue)": cholesterolMg,
            "user_\(CodingKeys.pantothenicAcidMg.rawValue)": pantothenicAcidMg,
            "user_\(CodingKeys.imageURL.rawValue)": imageURL,
            "user_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "user_\(CodingKeys.dateModified.rawValue)": dateModified,
            "user_\(CodingKeys.clickCount.rawValue)": clickCount,
            "user_\(CodingKeys.bookmarkCount.rawValue)": bookmarkCount,
            "user_\(CodingKeys.favouriteCount.rawValue)": favouriteCount
        ]
        return dict.compactMapValues({ $0 })
    }
    
    // swiftlint:disable:next function_parameter_count
    static func newIngredientTemplate(
        name: String,
        authorId: String,
        description: String? = nil,
        measurementMethod: MeasurementMethod = .weight,
        calories: Double?,
        protein: Double?,
        carbs: Double?,
        fatTotal: Double?,
        fatSaturated: Double? = nil,
        fatMonounsaturated: Double? = nil,
        fatPolyunsaturated: Double? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodiumMg: Double? = nil,
        potassiumMg: Double? = nil,
        calciumMg: Double? = nil,
        ironMg: Double? = nil,
        vitaminAMcg: Double? = nil,
        vitaminB6Mg: Double? = nil,
        vitaminB12Mcg: Double? = nil,
        vitaminCMg: Double? = nil,
        vitaminDMcg: Double? = nil,
        vitaminEMg: Double? = nil,
        vitaminKMcg: Double? = nil,
        magnesiumMg: Double? = nil,
        zincMg: Double? = nil,
        biotinMcg: Double? = nil,
        copperMg: Double? = nil,
        folateMcg: Double? = nil,
        iodineMcg: Double? = nil,
        niacinMg: Double? = nil,
        thiaminMg: Double? = nil,
        caffeineMg: Double? = nil,
        chlorideMg: Double? = nil,
        chromiumMcg: Double? = nil,
        seleniumMcg: Double? = nil,
        manganeseMg: Double? = nil,
        molybdenumMcg: Double? = nil,
        phosphorusMg: Double? = nil,
        riboflavinMg: Double? = nil,
        cholesterolMg: Double? = nil,
        pantothenicAcidMg: Double? = nil
    ) -> Self {
        IngredientTemplateModel(
            ingredientId: UUID().uuidString, authorId: authorId,
            name: name, description: description,
            measurementMethod: measurementMethod, calories: calories,
            protein: protein, carbs: carbs, fatTotal: fatTotal,
            fatSaturated: fatSaturated,
            fatMonounsaturated: fatMonounsaturated,
            fatPolyunsaturated: fatPolyunsaturated,
            fiber: fiber, sugar: sugar, sodiumMg: sodiumMg,
            potassiumMg: potassiumMg, calciumMg: calciumMg,
            ironMg: ironMg, vitaminAMcg: vitaminAMcg,
            vitaminB6Mg: vitaminB6Mg, vitaminB12Mcg: vitaminB12Mcg,
            vitaminCMg: vitaminCMg, vitaminDMcg: vitaminDMcg,
            vitaminEMg: vitaminEMg, vitaminKMcg: vitaminKMcg,
            magnesiumMg: magnesiumMg, zincMg: zincMg,
            biotinMcg: biotinMcg, copperMg: copperMg,
            folateMcg: folateMcg, iodineMcg: iodineMcg,
            niacinMg: niacinMg, thiaminMg: thiaminMg,
            caffeineMg: caffeineMg, chlorideMg: chlorideMg,
            chromiumMcg: chromiumMcg, seleniumMcg: seleniumMcg,
            manganeseMg: manganeseMg, molybdenumMcg: molybdenumMcg,
            phosphorusMg: phosphorusMg, riboflavinMg: riboflavinMg,
            cholesterolMg: cholesterolMg,
            pantothenicAcidMg: pantothenicAcidMg,
            imageURL: nil, dateCreated: .now, dateModified: .now,
            clickCount: 0, bookmarkCount: 0, favouriteCount: 0
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
                fatTotal: 6.9,
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
                fatTotal: 3.3,
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
