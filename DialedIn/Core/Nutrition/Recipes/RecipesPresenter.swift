//
//  RecipesPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI

@Observable
@MainActor
class RecipesPresenter {
    private let interactor: RecipesInteractor
    private let router: RecipesRouter
    
    init(interactor: RecipesInteractor,
         router: RecipesRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onRecipePressed(recipe: RecipeTemplateModel) {
        Task {
            interactor.trackEvent(event: Event.incrementRecipeStart)
            do {
                try await interactor.incrementRecipeTemplateInteraction(id: recipe.id)
                interactor.trackEvent(event: Event.incrementRecipeSuccess)
            } catch {
                interactor.trackEvent(event: Event.incrementRecipeFail(error: error))
            }
        }
        router.showRecipeDetailView(delegate: RecipeDetailDelegate(recipeTemplate: recipe))
    }

    enum Event: LoggableEvent {
        case incrementRecipeStart
        case incrementRecipeSuccess
        case incrementRecipeFail(error: Error)
        
        var eventName: String {
            switch self {
            case .incrementRecipeStart:              return "RecipesView_IncrementRecipe_Start"
            case .incrementRecipeSuccess:            return "RecipesView_IncrementRecipe_Success"
            case .incrementRecipeFail:               return "RecipesView_IncrementRecipe_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .incrementRecipeFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .incrementRecipeFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
