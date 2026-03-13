import SwiftUI

@Observable
@MainActor
class MealItemAmountViewPresenter {

    private let interactor: MealItemAmountViewInteractor
    private let router: MealItemAmountViewRouter
    private let onConfirm: (MealItemModel) -> Void
    private let isAddFoodMode: Bool
    private let unitNutrients: NutrientMap

    var amountText: String

    init(interactor: MealItemAmountViewInteractor, router: MealItemAmountViewRouter, delegate: MealItemAmountViewDelegate) {
        self.interactor = interactor
        self.router = router
        self.amountText = delegate.initialAmountText
        self.unitNutrients = delegate.unitNutrients
        self.onConfirm = delegate.onConfirm
        if case .addFood = delegate.mode {
            self.isAddFoodMode = true
        } else {
            self.isAddFoodMode = false
        }
    }

    var amountValue: Double { Double(amountText) ?? 0 }

    private var scale: Double {
        isAddFoodMode ? amountValue / 100 : amountValue
    }

    func scaledValue(for key: NutrientKey) -> Double {
        (unitNutrients[key] ?? 0) * scale
    }

    var calories: Double { scaledValue(for: .calories) }
    var protein: Double { scaledValue(for: .protein) }
    var fat: Double { scaledValue(for: .fatTotal) }
    var carbs: Double { scaledValue(for: .carbs) }

    func onViewAppear(delegate: MealItemAmountViewDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: MealItemAmountViewDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
    
    func onConfirmPressed(delegate: MealItemAmountViewDelegate) {
        let scaledNutrients = unitNutrients.mapValues { $0 * scale }
        let item: MealItemModel
        switch delegate.mode {
        case .addFood(let food):
            item = MealItemModel(
                itemId: UUID().uuidString,
                sourceType: .ingredient,
                sourceId: food.ingredientId,
                displayName: food.name,
                amount: amountValue,
                unit: delegate.unit,
                resolvedGrams: food.measurementMethod != .volume ? amountValue : nil,
                resolvedMilliliters: food.measurementMethod == .volume ? amountValue : nil,
                nutrients: scaledNutrients
            )
        case .editItem(let existing):
            let ratio = existing.amount > 0 ? amountValue / existing.amount : 0
            item = MealItemModel(
                itemId: existing.itemId,
                sourceType: existing.sourceType,
                sourceId: existing.sourceId,
                displayName: existing.displayName,
                amount: amountValue,
                unit: existing.unit,
                resolvedGrams: existing.resolvedGrams.map { $0 * ratio },
                resolvedMilliliters: existing.resolvedMilliliters.map { $0 * ratio },
                nutrients: scaledNutrients
            )
        }
        onConfirm(item)
        router.dismissScreen()
    }
}

extension MealItemAmountViewPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: MealItemAmountViewDelegate)
        case onDisappear(delegate: MealItemAmountViewDelegate)

        var eventName: String {
            switch self {
            case .onAppear:     return "MealItemAmountViewView_Appear"
            case .onDisappear:  return "MealItemAmountViewView_Disappear"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(let delegate), .onDisappear(let delegate):
                return delegate.eventParameters
            }
        }

        var type: LogType {
            return .analytic
        }
    }
}
