//
//  FoodsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class FoodsPresenter {
    private let interactor: FoodsInteractor
    private let router: FoodsRouter
    
    init(
        interactor: FoodsInteractor,
        router: FoodsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onIngredientPressed(ingredient: FoodModel) {
        router.showFoodDetailView(delegate: FoodDetailDelegate(food: ingredient))
    }
    
    // MARK: Analytics Events
    
    enum Event: LoggableEvent {
        case incrementIngredientStart
        case incrementIngredientSuccess
        case incrementIngredientFail(error: Error)

        var eventName: String {
            switch self {
            case .incrementIngredientStart:              return "FoodsView_IncrementIngredient_Start"
            case .incrementIngredientSuccess:            return "FoodsView_IncrementIngredient_Success"
            case .incrementIngredientFail:               return "FoodsView_IncrementIngredient_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .incrementIngredientFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .incrementIngredientFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
