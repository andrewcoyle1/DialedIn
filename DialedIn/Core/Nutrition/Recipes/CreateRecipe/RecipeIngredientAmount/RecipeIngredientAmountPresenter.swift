import Foundation

@Observable
@MainActor
class RecipeIngredientAmountPresenter {
    private let interactor: RecipeIngredientAmountInteractor
    private let router: RecipeIngredientAmountRouter

    var amountText: String = "100"

    var amountValue: Double { Double(amountText) ?? 0 }
    var scale: Double { max(amountValue, 0) / 100.0 }

    init(interactor: RecipeIngredientAmountInteractor, router: RecipeIngredientAmountRouter) {
        self.interactor = interactor
        self.router = router
    }

    func unitLabel(food: FoodModel) -> String {
        food.measurementMethod == .volume ? "ml" : "g"
    }

    func calories(food: FoodModel) -> Double? { food.calories.map { $0 * scale } }
    func protein(food: FoodModel) -> Double? { food.protein.map { $0 * scale } }
    func carbs(food: FoodModel) -> Double? { food.carbs.map { $0 * scale } }
    func fat(food: FoodModel) -> Double? { food.fatTotal.map { $0 * scale } }

    func confirm(delegate: RecipeIngredientAmountDelegate) {
        let unit: IngredientAmountUnit = delegate.food.measurementMethod == .volume ? .milliliters : .grams
        let model = RecipeIngredientModel(ingredient: delegate.food, amount: amountValue, unit: unit)
        delegate.onConfirm(model)
        router.dismissScreen()
    }
}

@MainActor
protocol RecipeIngredientAmountInteractor: GlobalInteractor { }

@MainActor
protocol RecipeIngredientAmountRouter: GlobalRouter { }

extension CoreInteractor: RecipeIngredientAmountInteractor { }
extension CoreRouter: RecipeIngredientAmountRouter { }
