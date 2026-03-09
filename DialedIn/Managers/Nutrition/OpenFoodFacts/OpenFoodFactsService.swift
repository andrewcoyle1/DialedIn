import Foundation
import FirebaseFunctions

/// Wrapper for DI container registration (protocols can't be directly keyed by type in the container)
@MainActor
final class OpenFoodFactsServiceContainer {
    let service: any OpenFoodFactsService
    init(_ service: any OpenFoodFactsService) { self.service = service }
}

@MainActor
protocol OpenFoodFactsService {
    func lookupBarcode(_ code: String) async throws -> FoodModel
    func searchFoods(query: String) async throws -> [FoodModel]
}

enum OFFError: LocalizedError {
    case productNotFound
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found. Try a different barcode."
        case .invalidResponse: return "Invalid response from Open Food Facts."
        }
    }
}

// MARK: - Production

final class ProductionOpenFoodFactsService: OpenFoodFactsService {
    private let session = URLSession.shared
    private let functions = Functions.functions(region: "us-central1")

    func lookupBarcode(_ code: String) async throws -> FoodModel {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(code).json") else {
            throw OFFError.invalidResponse
        }
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(OFFBarcodeResponse.self, from: data)
        guard response.status == 1, let product = response.product, let food = product.toFoodModel() else {
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
            return FoodModel(
                ingredientId: UUID().uuidString,
                authorId: nil,
                name: name,
                brandName: product["brandName"] as? String,
                measurementMethod: .weight,
                calories: product["calories"] as? Double,
                protein: product["protein"] as? Double,
                carbs: product["carbs"] as? Double,
                fatTotal: product["fatTotal"] as? Double,
                fatSaturated: product["fatSaturated"] as? Double,
                fiber: product["fiber"] as? Double,
                sugar: product["sugar"] as? Double,
                sodiumMg: product["sodiumMg"] as? Double,
                potassiumMg: product["potassiumMg"] as? Double,
                calciumMg: product["calciumMg"] as? Double,
                ironMg: product["ironMg"] as? Double,
                dateCreated: now,
                dateModified: now
            )
        }
    }
}

// MARK: - Mock

final class MockOpenFoodFactsService: OpenFoodFactsService {
    func lookupBarcode(_ code: String) async throws -> FoodModel {
        try await Task.sleep(nanoseconds: 500_000_000)
        return FoodModel.mocks[0]
    }

    func searchFoods(query: String) async throws -> [FoodModel] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return FoodModel.mocks
    }
}

// MARK: - DTOs

private struct OFFBarcodeResponse: Decodable {
    let status: Int
    let product: OFFProductDTO?
}

private struct OFFSearchResponse: Decodable {
    let products: [OFFProductDTO]?
}

private struct OFFProductDTO: Decodable {
    let productName: String?
    let brands: String?
    let nutriments: OFFNutrimentsDTO?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case nutriments
    }

    func toFoodModel() -> FoodModel? {
        guard let name = productName, !name.isEmpty else { return nil }
        let now = Date()
        return FoodModel(
            ingredientId: UUID().uuidString,
            authorId: nil,
            name: name,
            brandName: brands,
            measurementMethod: .weight,
            calories: nutriments?.energyKcal100g,
            protein: nutriments?.proteins100g,
            carbs: nutriments?.carbohydrates100g,
            fatTotal: nutriments?.fat100g,
            fatSaturated: nutriments?.saturatedFat100g,
            fiber: nutriments?.fiber100g,
            sugar: nutriments?.sugars100g,
            sodiumMg: nutriments?.sodium100g.map { $0 * 1000 },
            potassiumMg: nutriments?.potassium100g,
            calciumMg: nutriments?.calcium100g,
            ironMg: nutriments?.iron100g,
            dateCreated: now,
            dateModified: now
        )
    }
}

private struct OFFNutrimentsDTO: Decodable {
    let energyKcal100g: Double?
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

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
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
    }
}
