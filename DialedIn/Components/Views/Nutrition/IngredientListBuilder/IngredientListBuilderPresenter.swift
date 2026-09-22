import SwiftUI

@Observable
@MainActor
class IngredientListBuilderPresenter {
    
    private let interactor: IngredientListBuilderInteractor
    private let router: IngredientListBuilderRouter
    
    var isLoading: Bool = false
    var searchText: String = ""
    
    var userFoods: [FoodModel] {
        interactor.foods
            .filter { interactor.foodLogSettings.showBrandedFoods || $0.brandName == nil }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }

    var systemFoods: [FoodModel] = []

    var filteredFoods: [FoodModel] {
        interactor.foods
            .filter { interactor.foodLogSettings.showBrandedFoods || $0.brandName == nil }
            .filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description?.lowercased().contains(searchText.lowercased()) == true
            }
            .sortedByKeyPath(keyPath: \.name, ascending: true)
    }

    var currentUser: UserModel? {
        interactor.currentUser
    }

    var showFoodImageInLogger: Bool { interactor.foodLogSettings.showFoodImageInLogger }
    var showCaloriesInLogger: Bool { interactor.foodLogSettings.showCaloriesInLogger }
    var showMacrosInLogger: Bool { interactor.foodLogSettings.showMacrosInLogger }
    var showPortionInLogger: Bool { interactor.foodLogSettings.showPortionInLogger }

    init(interactor: IngredientListBuilderInteractor, router: IngredientListBuilderRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
        
    func onAddIngredientPressed(delegate: IngredientListBuilderDelegate) {
        interactor.trackEvent(event: Event.onAddIngredientPressed)
        router.showCreateFoodView(delegate: CreateFoodDelegate(mealItems: delegate.mealItems))
    }

    func onIngredientPressed(ingredient: FoodModel, onIngredientPressed: ((FoodModel) -> Void)?) {
        onIngredientPressed?(ingredient)
    }

    func navToIngredientAmountView(food: FoodModel, delegate: IngredientListBuilderDelegate) {
        if let recipeCallback = delegate.onRecipeIngredientConfirmed {
            router.showRecipeIngredientAmountView(delegate: RecipeIngredientAmountDelegate(
                food: food,
                onConfirm: recipeCallback
            ))
        } else if delegate.onMealItemConfirmed != nil {
            router.showMealItemAmountViewView(delegate: MealItemAmountViewDelegate(
                mode: .addFood(food),
                onConfirm: { item in delegate.onMealItemConfirmed?(item) }
            ))
        } else {
            delegate.onIngredientSelectionChanged?(food)
        }
    }

    func quickAdd(food: FoodModel, delegate: IngredientListBuilderDelegate) {
        if let recipeCallback = delegate.onRecipeIngredientConfirmed {
            let unit: IngredientAmountUnit = food.measurementMethod == .volume ? .milliliters : .grams
            let defaultAmount = food.portionGramsCalculated ?? food.portionMillilitersCalculated ?? 100
            recipeCallback(RecipeIngredientModel(ingredient: food, amount: defaultAmount, unit: unit))
        } else if delegate.onMealItemConfirmed != nil {
            let baseAmount = food.portionGramsCalculated ?? food.portionMillilitersCalculated ?? 100
            let scale = baseAmount / 100.0
            let nutrients = food.nutrients.mapValues { $0 * scale }
            let item = MealItemModel(
                itemId: UUID().uuidString,
                sourceType: .ingredient,
                sourceId: food.ingredientId,
                displayName: food.name,
                amount: food.portionQuantityCalculated ?? baseAmount,
                unit: food.portionNameCalculated ?? (food.measurementMethod == .volume ? "ml" : "g"),
                resolvedGrams: food.measurementMethod != .volume ? baseAmount : nil,
                resolvedMilliliters: food.measurementMethod == .volume ? baseAmount : nil,
                nutrients: nutrients
            )
            delegate.onMealItemConfirmed?(item)
        } else {
            delegate.onIngredientSelectionChanged?(food)
        }
    }

    // MARK: Analytics Events
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case onAddIngredientPressed

        var eventName: String {
            switch self {
            case .onAppear:                 return "IngredientsView_Appear"
            case .onDisappear:              return "IngredientsView_Disappear"
            case .onAddIngredientPressed:   return "IngredientsView_AddIngredientPressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}
