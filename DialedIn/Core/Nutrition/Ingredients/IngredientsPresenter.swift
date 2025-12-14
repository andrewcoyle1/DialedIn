//
//  IngredientsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import Foundation

@Observable
@MainActor
class IngredientsPresenter {
    private let interactor: IngredientsInteractor
    private let router: IngredientsRouter
    
    init(
        interactor: IngredientsInteractor,
        router: IngredientsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onIngredientPressed(ingredient: IngredientTemplateModel) {
        Task {
            interactor.trackEvent(event: Event.incrementIngredientStart)
            do {
                try await interactor.incrementIngredientTemplateInteraction(id: ingredient.id)
                interactor.trackEvent(event: Event.incrementIngredientSuccess)
            } catch {
                interactor.trackEvent(event: Event.incrementIngredientFail(error: error))
            }
        }
        router.showIngredientDetailView(delegate: IngredientDetailDelegate(ingredientTemplate: ingredient))
    }
    
    // MARK: Analytics Events
    
    enum Event: LoggableEvent {
        case incrementIngredientStart
        case incrementIngredientSuccess
        case incrementIngredientFail(error: Error)

        var eventName: String {
            switch self {
            case .incrementIngredientStart:              return "IngredientsView_IncrementIngredient_Start"
            case .incrementIngredientSuccess:            return "IngredientsView_IncrementIngredient_Success"
            case .incrementIngredientFail:               return "IngredientsView_IncrementIngredient_Fail"
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
