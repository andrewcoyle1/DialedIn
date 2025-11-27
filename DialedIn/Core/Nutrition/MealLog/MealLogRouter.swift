//
//  MealLogRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol MealLogRouter {
    func showAddMealView(delegate: AddMealDelegate)
    func showMealDetailView(delegate: MealDetailDelegate)
    func showAlert(error: Error)
}

extension CoreRouter: MealLogRouter { }
