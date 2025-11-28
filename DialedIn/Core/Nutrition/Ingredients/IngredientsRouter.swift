//
//  IngredientsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol IngredientsRouter {
    func showIngredientDetailView(delegate: IngredientDetailDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: IngredientsRouter { }
