//
//  IngredientsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol IngredientsInteractor {
    func incrementIngredientTemplateInteraction(id: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: IngredientsInteractor { }
