//
//  Macro.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import SwiftUI

enum Macro: CaseIterable {
    case cals
    case fat
    case protein
    case carbs

    var title: String {
        switch self {
        case .cals: return "Cals"
        case .carbs: return "Carbs"
        case .fat: return "Fat"
        case .protein: return "Protein"
        }
    }

    var iconName: String {
        switch self {
        case .cals: return "flame"
        case .carbs: return "carrot"
        case .fat: return "drop"
        case .protein: return "bolt"
        }
    }

    var colour: Color {
        switch self {
        case .cals: return .blue
        case .carbs: return .carbsColor
        case .fat: return .fatColor
        case .protein: return .proteinColor
        }
    }

    var nutrientKey: NutrientKey {
        switch self {
        case .cals: return .calories
        case .fat: return .fatTotal
        case .protein: return .protein
        case .carbs: return .carbs
        }
    }

    static var proteinColor: Color { Color(red: 0.9, green: 0.4, blue: 0.3) }
    static var fatColor: Color { Color(red: 0.95, green: 0.75, blue: 0.2) }
    static var carbsColor: Color { Color(red: 0.4, green: 0.75, blue: 0.5) }
}

protocol MacroNutrient {
    var name: String { get }
    var unit: String { get }
}

enum Macros: String, CaseIterable {
    case protein
    case fat
    case carbs
    case vitamins
    case minerals
    case other

    var name: String {
        switch self {
        case .carbs: return "Carbohydrates"
        case .fat: return "Fat"
        case .protein: return "Protein"
        case .vitamins: return "Vitamins"
        case .minerals: return "Minerals"
        case .other: return "Other"
        }
    }

    var details: [NutrientKey] {
        NutrientKey.allCases.filter { $0.category == self }
    }
}

enum NutrientKey: String, CaseIterable, Codable, Hashable, MacroNutrient {
    // Core macros
    case calories
    case protein
    case carbs
    case fatTotal             = "fat_total"
    // Fat breakdown
    case fatSaturated         = "fat_saturated"
    case fatMonounsaturated   = "fat_monounsaturated"
    case fatPolyunsaturated   = "fat_polyunsaturated"
    // Carb breakdown
    case fiber
    case sugar
    // Minerals
    case sodiumMg             = "sodium_mg"
    case potassiumMg          = "potassium_mg"
    case calciumMg            = "calcium_mg"
    case ironMg               = "iron_mg"
    case magnesiumMg          = "magnesium_mg"
    case zincMg               = "zinc_mg"
    case copperMg             = "copper_mg"
    case manganeseMg          = "manganese_mg"
    case phosphorusMg         = "phosphorus_mg"
    case seleniumMcg          = "selenium_mcg"
    case chlorideMg           = "chloride_mg"
    case chromiumMcg          = "chromium_mcg"
    case molybdenumMcg        = "molybdenum_mcg"
    // Vitamins
    case vitaminAMcg          = "vitamin_a_mcg"
    case vitaminB6Mg          = "vitamin_b6_mg"
    case vitaminB12Mcg        = "vitamin_b12_mcg"
    case vitaminCMg           = "vitamin_c_mg"
    case vitaminDMcg          = "vitamin_d_mcg"
    case vitaminEMg           = "vitamin_e_mg"
    case vitaminKMcg          = "vitamin_k_mcg"
    case biotinMcg            = "biotin_mcg"
    case folateMcg            = "folate_mcg"
    case iodineMcg            = "iodine_mcg"
    case niacinMg             = "niacin_mg"
    case thiaminMg            = "thiamin_mg"
    case riboflavinMg         = "riboflavin_mg"
    case pantothenicAcidMg    = "pantothenic_acid_mg"
    // Other
    case caffeineMg           = "caffeine_mg"
    case cholesterolMg        = "cholesterol_mg"

    var name: String {
        switch self {
        case .calories:           return "Calories"
        case .protein:            return "Protein"
        case .carbs:              return "Carbohydrates"
        case .fatTotal:           return "Total Fat"
        case .fatSaturated:       return "Saturated Fat"
        case .fatMonounsaturated: return "Monounsaturated Fat"
        case .fatPolyunsaturated: return "Polyunsaturated Fat"
        case .fiber:              return "Fiber"
        case .sugar:              return "Sugar"
        case .sodiumMg:           return "Sodium"
        case .potassiumMg:        return "Potassium"
        case .calciumMg:          return "Calcium"
        case .ironMg:             return "Iron"
        case .magnesiumMg:        return "Magnesium"
        case .zincMg:             return "Zinc"
        case .copperMg:           return "Copper"
        case .manganeseMg:        return "Manganese"
        case .phosphorusMg:       return "Phosphorus"
        case .seleniumMcg:        return "Selenium"
        case .chlorideMg:         return "Chloride"
        case .chromiumMcg:        return "Chromium"
        case .molybdenumMcg:      return "Molybdenum"
        case .vitaminAMcg:        return "Vitamin A"
        case .vitaminB6Mg:        return "Vitamin B6"
        case .vitaminB12Mcg:      return "Vitamin B12"
        case .vitaminCMg:         return "Vitamin C"
        case .vitaminDMcg:        return "Vitamin D"
        case .vitaminEMg:         return "Vitamin E"
        case .vitaminKMcg:        return "Vitamin K"
        case .biotinMcg:          return "Biotin"
        case .folateMcg:          return "Folate"
        case .iodineMcg:          return "Iodine"
        case .niacinMg:           return "Niacin"
        case .thiaminMg:          return "Thiamin"
        case .riboflavinMg:       return "Riboflavin"
        case .pantothenicAcidMg:  return "Pantothenic Acid"
        case .caffeineMg:         return "Caffeine"
        case .cholesterolMg:      return "Cholesterol"
        }
    }

    var unit: String {
        switch self {
        case .calories:
            return "kcal"
        case .protein, .carbs, .fatTotal, .fatSaturated, .fatMonounsaturated,
             .fatPolyunsaturated, .fiber, .sugar:
            return "g"
        case .sodiumMg, .potassiumMg, .calciumMg, .ironMg, .magnesiumMg, .zincMg, .copperMg,
             .manganeseMg, .phosphorusMg, .chlorideMg, .vitaminB6Mg, .vitaminCMg, .vitaminEMg,
             .niacinMg, .thiaminMg, .riboflavinMg, .pantothenicAcidMg, .caffeineMg, .cholesterolMg:
            return "mg"
        case .seleniumMcg, .chromiumMcg, .molybdenumMcg, .vitaminAMcg, .vitaminB12Mcg,
             .vitaminDMcg, .vitaminKMcg, .biotinMcg, .folateMcg, .iodineMcg:
            return "mcg"
        }
    }

    var category: Macros? {
        switch self {
        case .calories:
            return nil
        case .protein:
            return .protein
        case .carbs, .fiber, .sugar:
            return .carbs
        case .fatTotal, .fatSaturated, .fatMonounsaturated, .fatPolyunsaturated:
            return .fat
        case .sodiumMg, .potassiumMg, .calciumMg, .ironMg, .magnesiumMg, .zincMg, .copperMg,
             .manganeseMg, .phosphorusMg, .seleniumMcg, .chlorideMg, .chromiumMcg, .molybdenumMcg:
            return .minerals
        case .vitaminAMcg, .vitaminB6Mg, .vitaminB12Mcg, .vitaminCMg, .vitaminDMcg, .vitaminEMg,
             .vitaminKMcg, .biotinMcg, .folateMcg, .iodineMcg, .niacinMg, .thiaminMg, .riboflavinMg,
             .pantothenicAcidMg:
            return .vitamins
        case .caffeineMg, .cholesterolMg:
            return .other
        }
    }
}
