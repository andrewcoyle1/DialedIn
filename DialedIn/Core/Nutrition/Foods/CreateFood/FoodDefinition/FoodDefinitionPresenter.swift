import SwiftUI

@Observable
@MainActor
class FoodDefinitionPresenter {
    
    private let interactor: FoodDefinitionInteractor
    private let router: FoodDefinitionRouter
    
    var foodDefinitionOption: FoodDefinitionOption = .foodDetail
    
    var nutritionWeightUnit: NutritionWeightUnit = .grams
    var energyUnit: EnergyUnit = .kcal

    var isShowingMacros: Bool = true
    
    var energy: Double?
    var protein: Double?
    var carbs: Double?
    var fats: Double?
    var fiber: Double?
    var starch: Double?
    var sugars: Double?
    var addedSugars: Double?
    var monounsaturatedFats: Double?
    var polyunsaturatedFats: Double?
    var omega3: Double?
    var omega3Ala: Double?
    var omega3Dha: Double?
    var omega3Epa: Double?
    var omega6: Double?
    var saturatedFats: Double?
    var transFats: Double?

    var cysteine: Double?
    var histidine: Double?
    var isoleucine: Double?
    var leucine: Double?
    var lysine: Double?
    var methionine: Double?
    var phenylalinine: Double?
    var threonine: Double?
    var tryptophan: Double?
    var tyrosine: Double?
    var valine: Double?

    var b1Thiamine: Double?
    var b2Riboflavin: Double?
    var b3Niacin: Double?
    var b5PantothenicAcid: Double?
    var b6Pyridoxine: Double?
    var b12Cobalamin: Double?
    var folate: Double?
    var vitaminA: Double?
    var vitaminC: Double?
    var vitaminD: Double?
    var vitaminE: Double?
    var vitaminK: Double?

    var calcium: Double?
    var copper: Double?
    var iron: Double?
    var magnesium: Double?
    var manganese: Double?
    var phosphorus: Double?
    var potassium: Double?
    var selenium: Double?
    var sodium: Double?
    var zinc: Double?

    var alcohol: Double?
    var caffeine: Double?
    var cholesterol: Double?
    var choline: Double?
    var water: Double?
    
    init(interactor: FoodDefinitionInteractor, router: FoodDefinitionRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: FoodDefinitionDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: FoodDefinitionDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onCreatePressed(delegate: FoodDefinitionDelegate) {
        guard let userId = interactor.currentUser?.userId else { return }
        Task {
            interactor.trackEvent(event: Event.createFoodStart)
            do {
                _ = try await self.createFood(userId: userId, delegate: delegate)
                router.dismissScreen()
            } catch {
                interactor.trackEvent(event: Event.createFoodFail(error: error))
            }
        }
    }
    
    func onCreateAndAddPressed(delegate: FoodDefinitionDelegate) {
        guard let userId = interactor.currentUser?.userId else { return }
        Task {
            interactor.trackEvent(event: Event.createFoodStart)
            do {
                let food = try await self.createFood(userId: userId, delegate: delegate)
                let mealLogItem = MealItemModel(
                    itemId: UUID().uuidString,
                    sourceType: .ingredient,
                    sourceId: food.id,
                    displayName: food.name,
                    amount: 100,
                    unit: "grams"
                )
                delegate.mealItems?.wrappedValue.append(mealLogItem)
                router.dismissScreen()
            } catch {
                interactor.trackEvent(event: Event.createFoodFail(error: error))
            }
        }
    }
    
    private func createFood(userId: String, delegate: FoodDefinitionDelegate) async throws -> FoodModel {
        var nutrients: NutrientMap = NutrientMap()
        func set(_ key: NutrientKey, _ value: Double?) {
            if let val = value { nutrients[key] = val }
        }
        set(.calories, self.energy)
        set(.protein, self.protein)
        set(.carbs, self.carbs)
        set(.fatTotal, self.fats)
        set(.fatSaturated, self.saturatedFats)
        set(.fatMonounsaturated, self.monounsaturatedFats)
        set(.fatPolyunsaturated, self.polyunsaturatedFats)
        set(.fiber, self.fiber)
        set(.sugar, self.sugars)
        set(.sodiumMg, self.sodium)
        set(.potassiumMg, self.potassium)
        set(.calciumMg, self.calcium)
        set(.ironMg, self.iron)
        set(.vitaminAMcg, self.vitaminA)
        set(.vitaminB6Mg, self.b6Pyridoxine)
        set(.vitaminB12Mcg, self.b12Cobalamin)
        set(.vitaminCMg, self.vitaminC)
        set(.vitaminDMcg, self.vitaminD)
        set(.vitaminEMg, self.vitaminE)
        set(.vitaminKMcg, self.vitaminK)
        set(.magnesiumMg, self.magnesium)
        set(.zincMg, self.zinc)
        set(.copperMg, self.copper)
        set(.folateMcg, self.folate)
        set(.niacinMg, self.b3Niacin)
        set(.thiaminMg, self.b1Thiamine)
        set(.caffeineMg, self.caffeine)
        set(.seleniumMcg, self.selenium)
        set(.manganeseMg, self.manganese)
        set(.phosphorusMg, self.phosphorus)
        set(.riboflavinMg, self.b2Riboflavin)
        set(.cholesterolMg, self.cholesterol)
        set(.pantothenicAcidMg, self.b5PantothenicAcid)

        // Normalize to per-100g so all downstream callers work correctly
        if case .serving = delegate.nutritionDefinitionOption,
           let weight = delegate.servingWeight, weight > 0 {
            nutrients = nutrients.mapValues { $0 * (100.0 / weight) }
        }

        let ingredient = FoodModel(
            authorId: userId,
            name: delegate.name,
            brandName: delegate.brandName,
            description: nil,
            measurementMethod: .weight,
            nutrients: nutrients,
            barcode: delegate.barcode,
            servingWeight: delegate.servingWeight,
            portionSize: delegate.portionSize,
            portionName: delegate.portionName,
            portionWeight: delegate.portionWeight,
            weightPortionSize: delegate.weightPortionSize,
            weightPortionName: delegate.weightPortionName,
            portionVolume: delegate.portionVolume,
            volumePortionSize: delegate.volumePortionSize,
            volumePortionName: delegate.volumePortionName
        )
        try await interactor.saveFood(ingredient, image: delegate.image)
        return ingredient
    }
}

extension FoodDefinitionPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: FoodDefinitionDelegate)
        case onDisappear(delegate: FoodDefinitionDelegate)
        case createFoodStart
        case createFoodSuccess
        case createFoodFail(error: Error)
        
        var eventName: String {
            switch self {
            case .onAppear:             return "FoodDefinitionView_Appear"
            case .onDisappear:          return "FoodDefinitionView_Disappear"
            case .createFoodStart:      return "FoodDefinitionView_CreateFood_Start"
            case .createFoodSuccess:    return "FoodDefinitionView_CreateFood_Success"
            case .createFoodFail:       return "FoodDefinitionView_CreateFood_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .createFoodFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .createFoodFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
