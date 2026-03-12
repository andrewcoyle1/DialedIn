//
//  ProductionOpenFoodFactsService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import Foundation
import FirebaseFunctions

final class ProductionOpenFoodFactsService: OpenFoodFactsService {
    private let session = URLSession.shared
    private let functions = Functions.functions(region: "us-central1")

    func lookupBarcode(_ code: String) async throws -> FoodModel {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(code).json") else {
            throw OFFError.invalidResponse
        }
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(OFFBarcodeResponse.self, from: data)
        guard response.status == 1, let product = response.product, let food = product.toFoodModel(barcode: code) else {
            throw OFFError.productNotFound
        }
        return food
    }

    func searchFoods(query: String) async throws -> [FoodModel] {
        let result = try await functions.httpsCallable("foodSearch").call(["query": query])
        guard let dict = result.data as? [String: Any],
              let rawProducts = dict["products"] as? [Any] else {
            return []
        }
        let products = rawProducts.compactMap { $0 as? [String: Any] }
        let now = Date()
        return products.compactMap { product -> FoodModel? in
            guard let name = product["name"] as? String else { return nil }
            let servingSize = product["servingSize"] as? String
            let parsed = servingSize.map { parseServingSize($0) }

            var nutrients: [NutrientKey: Double] = [:]
            func set(_ key: NutrientKey, _ kVal: String) {
                if let val = product[kVal] as? Double { nutrients[key] = val }
            }
            set(.calories, "calories")
            set(.protein, "protein")
            set(.carbs, "carbs")
            set(.fatTotal, "fatTotal")
            set(.fatSaturated, "fatSaturated")
            set(.fiber, "fiber")
            set(.sugar, "sugar")
            set(.sodiumMg, "sodiumMg")
            set(.potassiumMg, "potassiumMg")
            set(.calciumMg, "calciumMg")
            set(.ironMg, "ironMg")
            set(.vitaminAMcg, "vitaminAMcg")
            set(.vitaminB6Mg, "vitaminB6Mg")
            set(.vitaminB12Mcg, "vitaminB12Mcg")
            set(.vitaminCMg, "vitaminCMg")
            set(.vitaminDMcg, "vitaminDMcg")
            set(.vitaminEMg, "vitaminEMg")
            set(.vitaminKMcg, "vitaminKMcg")
            set(.magnesiumMg, "magnesiumMg")
            set(.zincMg, "zincMg")
            set(.biotinMcg, "biotinMcg")
            set(.copperMg, "copperMg")
            set(.folateMcg, "folateMcg")
            set(.iodineMcg, "iodineMcg")
            set(.niacinMg, "niacinMg")
            set(.thiaminMg, "thiaminMg")
            set(.caffeineMg, "caffeineMg")
            set(.chlorideMg, "chlorideMg")
            set(.seleniumMcg, "seleniumMcg")
            set(.manganeseMg, "manganeseMg")
            set(.phosphorusMg, "phosphorusMg")
            set(.riboflavinMg, "riboflavinMg")
            set(.cholesterolMg, "cholesterolMg")
            set(.pantothenicAcidMg, "pantothenicAcidMg")

            return FoodModel(
                ingredientId: UUID().uuidString,
                authorId: nil,
                name: name,
                brandName: product["brandName"] as? String,
                measurementMethod: .weight,
                nutrients: nutrients,
                servingWeight: product["servingWeight"] as? Double,
                portionSize: parsed?.portionSize,
                portionName: parsed?.portionName,
                imageURL: product["imageURL"] as? String,
                dateCreated: now,
                dateModified: now
            )
        }
    }
}
