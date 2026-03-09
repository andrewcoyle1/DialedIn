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
        let ingredient = FoodModel(
            authorId: userId,
            name: delegate.name,
            brandName: delegate.brandName,
            description: nil,
            measurementMethod: .weight,
            calories: self.energy,
            protein: self.protein,
            carbs: self.carbs,
            fatTotal: self.fats,
            fatSaturated: self.saturatedFats,
            fatMonounsaturated: self.monounsaturatedFats,
            fatPolyunsaturated: self.polyunsaturatedFats,
            fiber: self.fiber,
            sugar: self.sugars,
            sodiumMg: self.sodium,
            potassiumMg: self.potassium,
            calciumMg: self.calcium,
            ironMg: self.iron,
            vitaminAMcg: self.vitaminA,
            vitaminB6Mg: self.b6Pyridoxine,
            vitaminB12Mcg: self.b12Cobalamin,
            vitaminCMg: self.vitaminC,
            vitaminDMcg: self.vitaminD,
            vitaminEMg: self.vitaminE,
            vitaminKMcg: self.vitaminK,
            magnesiumMg: self.magnesium,
            zincMg: self.zinc,
            biotinMcg: nil,
            copperMg: self.copper,
            folateMcg: self.folate,
            iodineMcg: nil,
            niacinMg: self.b3Niacin,
            thiaminMg: self.b1Thiamine,
            caffeineMg: self.caffeine,
            chlorideMg: nil,
            chromiumMcg: nil,
            seleniumMcg: self.selenium,
            manganeseMg: self.manganese,
            molybdenumMcg: nil,
            phosphorusMg: self.phosphorus,
            riboflavinMg: self.b2Riboflavin,
            cholesterolMg: self.cholesterol,
            pantothenicAcidMg: self.b5PantothenicAcid
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
