//
//  IngredientDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol IngredientDetailInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: IngredientDetailInteractor { }
