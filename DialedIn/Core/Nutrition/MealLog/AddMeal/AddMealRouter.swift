//
//  AddMealRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol AddMealRouter {
    func showNutritionLibraryPickerView(delegate: NutritionLibraryPickerDelegate)
    func dismissScreen()
}

extension CoreRouter: AddMealRouter { }
