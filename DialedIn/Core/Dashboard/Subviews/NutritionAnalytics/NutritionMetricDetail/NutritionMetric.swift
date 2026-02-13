//
//  NutritionMetric.swift
//  DialedIn
//
//  Created by Cursor on 06/02/2026.
//

import SwiftUI

/// Defines each nutrition metric card and how to extract its value from daily data.
enum NutritionMetric {
    // Calories & Macros
    case macros
    case calories
    case protein
    case fat
    case carbs

    // Carb Breakdown
    case fiber
    case netCarbs
    case starch
    case sugars
    case sugarsAdded

    // Fat Breakdown
    case fatMono
    case fatPoly
    case omega3
    case omega3ALA
    case omega3DHA
    case omega3EPA
    case omega6
    case fatSaturated
    case transFat

    // Protein Breakdown (amino acids)
    case cysteine
    case histidine
    case isoleucine
    case leucine
    case lysine
    case methionine
    case phenylalanine
    case threonine
    case tryptophan
    case tyrosine
    case valine

    // Vitamin Breakdown
    case thiamin
    case riboflavin
    case niacin
    case pantothenicAcid
    case vitaminB6
    case vitaminB12
    case folate
    case vitaminA
    case vitaminC
    case vitaminD
    case vitaminE
    case vitaminK

    // Mineral Breakdown
    case calcium
    case copper
    case iron
    case magnesium
    case manganese
    case phosphorus
    case potassium
    case selenium
    case sodium
    case zinc

    // Other Breakdown
    case alcohol
    case caffeine
    case cholesterol
    case choline
    case water

    var title: String {
        switch self {
        case .macros: return "Macros"
        case .calories: return "Calories"
        case .protein: return "Protein"
        case .fat: return "Fat"
        case .carbs: return "Carbs"
        case .fiber: return "Fiber"
        case .netCarbs: return "Net (Non-fiber)"
        case .starch: return "Starch"
        case .sugars: return "Sugars"
        case .sugarsAdded: return "Sugars Added"
        case .fatMono: return "Monounsaturated"
        case .fatPoly: return "Polyunsaturated"
        case .omega3: return "Omega-3"
        case .omega3ALA: return "Omega-3 ALA"
        case .omega3DHA: return "Omega-3 DHA"
        case .omega3EPA: return "Omega-3 EPA"
        case .omega6: return "Omega-6"
        case .fatSaturated: return "Saturated"
        case .transFat: return "Trans Fat"
        case .cysteine: return "Cysteine"
        case .histidine: return "Histidine"
        case .isoleucine: return "Isoleucine"
        case .leucine: return "Leucine"
        case .lysine: return "Lysine"
        case .methionine: return "Methionine"
        case .phenylalanine: return "Phenylalanine"
        case .threonine: return "Threonine"
        case .tryptophan: return "Tryptophan"
        case .tyrosine: return "Tyrosine"
        case .valine: return "Valine"
        case .thiamin: return "B1, Thiamine"
        case .riboflavin: return "B2, Riboflavin"
        case .niacin: return "B3, Niacin"
        case .pantothenicAcid: return "B5, Pantothenic Acid"
        case .vitaminB6: return "B6, Pyridoxine"
        case .vitaminB12: return "B12, Cobalamin"
        case .folate: return "Folate"
        case .vitaminA: return "Vitamin A"
        case .vitaminC: return "Vitamin C"
        case .vitaminD: return "Vitamin D"
        case .vitaminE: return "Vitamin E"
        case .vitaminK: return "Vitamin K"
        case .calcium: return "Calcium"
        case .copper: return "Copper"
        case .iron: return "Iron"
        case .magnesium: return "Magnesium"
        case .manganese: return "Manganese"
        case .phosphorus: return "Phosphorus"
        case .potassium: return "Potassium"
        case .selenium: return "Selenium"
        case .sodium: return "Sodium"
        case .zinc: return "Zinc"
        case .alcohol: return "Alcohol"
        case .caffeine: return "Caffeine"
        case .cholesterol: return "Cholesterol"
        case .choline: return "Choline"
        case .water: return "Water"
        }
    }

    var yAxisSuffix: String {
        switch self {
        case .macros, .calories: return " kcal"
        case .protein, .fat, .carbs, .fiber, .netCarbs, .starch, .sugars, .sugarsAdded,
             .fatMono, .fatPoly, .omega3, .omega3ALA, .omega3DHA, .omega3EPA, .omega6,
             .fatSaturated, .transFat, .alcohol, .water,
             .cysteine, .histidine, .isoleucine, .leucine, .lysine, .methionine,
             .phenylalanine, .threonine, .tryptophan, .tyrosine, .valine:
            return " g"
        case .thiamin, .riboflavin, .niacin, .pantothenicAcid, .vitaminB6, .vitaminC, .vitaminE,
             .calcium, .copper, .iron, .magnesium, .manganese, .phosphorus, .potassium,
             .sodium, .zinc, .choline, .cholesterol, .caffeine:
            return " mg"
        case .vitaminB12, .vitaminA, .vitaminD, .vitaminK, .folate, .selenium:
            return " mcg"
        }
    }

    var chartColor: Color {
        switch self {
        case .macros, .calories: return .blue
        case .protein, .cysteine, .histidine, .isoleucine, .leucine, .lysine, .methionine,
             .phenylalanine, .threonine, .tryptophan, .tyrosine, .valine:
            return MacroProgressChart.proteinColor
        case .fat, .fatMono, .fatPoly, .omega3, .omega3ALA, .omega3DHA, .omega3EPA,
             .omega6, .fatSaturated, .transFat:
            return MacroProgressChart.fatColor
        case .carbs, .fiber, .netCarbs, .starch, .sugars, .sugarsAdded:
            return MacroProgressChart.carbsColor
        case .thiamin, .riboflavin, .niacin, .pantothenicAcid, .vitaminB6, .vitaminB12,
             .folate, .vitaminA, .vitaminC, .vitaminD, .vitaminE, .vitaminK:
            return MacroProgressChart.vitaminColor
        case .calcium, .copper, .iron, .magnesium, .manganese, .phosphorus,
             .potassium, .selenium, .sodium, .zinc:
            return MacroProgressChart.mineralColor
        case .alcohol, .caffeine, .cholesterol, .choline, .water:
            return MacroProgressChart.otherColor
        }
    }

    var systemImageName: String {
        switch self {
        case .macros, .calories: return "flame.fill"
        case .protein, .cysteine, .histidine, .isoleucine, .leucine, .lysine, .methionine,
             .phenylalanine, .threonine, .tryptophan, .tyrosine, .valine:
            return "fork.knife"
        case .fat, .fatMono, .fatPoly, .omega3, .omega3ALA, .omega3DHA, .omega3EPA,
             .omega6, .fatSaturated, .transFat:
            return "drop.fill"
        case .carbs, .fiber, .netCarbs, .starch, .sugars, .sugarsAdded:
            return "leaf.fill"
        case .thiamin, .riboflavin, .niacin, .pantothenicAcid, .vitaminB6, .vitaminB12,
             .folate, .vitaminA, .vitaminC, .vitaminD, .vitaminE, .vitaminK:
            return "pills.fill"
        case .calcium, .copper, .iron, .magnesium, .manganese, .phosphorus,
             .potassium, .selenium, .sodium, .zinc:
            return "diamond.fill"
        case .alcohol: return "wineglass.fill"
        case .caffeine: return "cup.and.saucer.fill"
        case .cholesterol, .choline, .water: return "drop.fill"
        }
    }

    /// Metrics that have no extractable value from totals or breakdown (e.g. not in HealthKit breakdown).
    private static let metricsReturningNil: Set<NutritionMetric> = [
        .starch, .sugarsAdded, .omega3, .omega3ALA, .omega3DHA, .omega3EPA, .omega6, .transFat,
        .cysteine, .histidine, .isoleucine, .leucine, .lysine, .methionine,
        .phenylalanine, .threonine, .tryptophan, .tyrosine, .valine,
        .alcohol, .choline, .water
    ]

    /// Extracts the metric value from daily totals and/or breakdown.
    /// For macro metrics, use totals; for breakdown metrics, use breakdown.
    func extractValue(totals: DailyMacroTarget?, breakdown: DailyNutritionBreakdown?) -> Double? {
        if Self.metricsReturningNil.contains(self) { return nil }
        if usesTotals { return extractFromTotals(totals) }
        return extractFromBreakdown(breakdown)
    }

    private func extractFromTotals(_ totals: DailyMacroTarget?) -> Double? {
        guard let totals else { return nil }
        switch self {
        case .macros, .calories: return totals.calories
        case .protein: return totals.proteinGrams
        case .fat: return totals.fatGrams
        case .carbs: return totals.carbGrams
        default: return nil
        }
    }

    private func extractFromBreakdown(_ breakdown: DailyNutritionBreakdown?) -> Double? {
        switch self {
        case .fiber, .netCarbs, .sugars, .fatMono, .fatPoly, .fatSaturated, .caffeine, .cholesterol:
            return extractBreakdownCarbsFatsOther(breakdown)
        case .thiamin, .riboflavin, .niacin, .pantothenicAcid, .vitaminB6, .vitaminB12, .folate:
            return extractBreakdownVitaminsB(breakdown)
        case .vitaminA, .vitaminC, .vitaminD, .vitaminE, .vitaminK:
            return extractBreakdownVitaminsOther(breakdown)
        case .calcium, .copper, .iron, .magnesium, .manganese, .phosphorus,
             .potassium, .selenium, .sodium, .zinc:
            return extractBreakdownMinerals(breakdown)
        default:
            return nil
        }
    }

    private func extractBreakdownCarbsFatsOther(_ breakdown: DailyNutritionBreakdown?) -> Double? {
        guard let breakdown else { return nil }
        switch self {
        case .fiber: return breakdown.fiberGrams
        case .netCarbs: return breakdown.netCarbsGrams
        case .sugars: return breakdown.sugarGrams
        case .fatMono: return breakdown.fatMonounsaturatedGrams
        case .fatPoly: return breakdown.fatPolyunsaturatedGrams
        case .fatSaturated: return breakdown.fatSaturatedGrams
        case .caffeine: return breakdown.caffeineMg
        case .cholesterol: return breakdown.cholesterolMg
        default: return nil
        }
    }

    private func extractBreakdownVitaminsB(_ breakdown: DailyNutritionBreakdown?) -> Double? {
        guard let breakdown else { return nil }
        switch self {
        case .thiamin: return breakdown.thiaminMg
        case .riboflavin: return breakdown.riboflavinMg
        case .niacin: return breakdown.niacinMg
        case .pantothenicAcid: return breakdown.pantothenicAcidMg
        case .vitaminB6: return breakdown.vitaminB6Mg
        case .vitaminB12: return breakdown.vitaminB12Mcg
        case .folate: return breakdown.folateMcg
        default: return nil
        }
    }

    private func extractBreakdownVitaminsOther(_ breakdown: DailyNutritionBreakdown?) -> Double? {
        guard let breakdown else { return nil }
        switch self {
        case .vitaminA: return breakdown.vitaminAMcg
        case .vitaminC: return breakdown.vitaminCMg
        case .vitaminD: return breakdown.vitaminDMcg
        case .vitaminE: return breakdown.vitaminEMg
        case .vitaminK: return breakdown.vitaminKMcg
        default: return nil
        }
    }

    private func extractBreakdownMinerals(_ breakdown: DailyNutritionBreakdown?) -> Double? {
        guard let breakdown else { return nil }
        if let value = extractBreakdownMineralsFirstGroup(breakdown) { return value }
        return extractBreakdownMineralsSecondGroup(breakdown)
    }

    private func extractBreakdownMineralsFirstGroup(_ breakdown: DailyNutritionBreakdown) -> Double? {
        switch self {
        case .calcium: return breakdown.calciumMg
        case .copper: return breakdown.copperMg
        case .iron: return breakdown.ironMg
        case .magnesium: return breakdown.magnesiumMg
        case .manganese: return breakdown.manganeseMg
        default: return nil
        }
    }

    private func extractBreakdownMineralsSecondGroup(_ breakdown: DailyNutritionBreakdown) -> Double? {
        switch self {
        case .phosphorus: return breakdown.phosphorusMg
        case .potassium: return breakdown.potassiumMg
        case .selenium: return breakdown.seleniumMcg
        case .sodium: return breakdown.sodiumMg
        case .zinc: return breakdown.zincMg
        default: return nil
        }
    }

    /// Whether this metric uses DailyMacroTarget (totals) for its data source.
    var usesTotals: Bool {
        switch self {
        case .macros, .calories, .protein, .fat, .carbs: return true
        default: return false
        }
    }
}
