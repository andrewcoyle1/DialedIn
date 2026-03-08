//
//  IngredientsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol IngredientsRouter {
    func showFoodDetailView(delegate: FoodDetailDelegate)
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: IngredientsRouter { }
