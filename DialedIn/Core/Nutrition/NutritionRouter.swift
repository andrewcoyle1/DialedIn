//
//  NutritionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol NutritionRouter: GlobalRouter {
    func showNotificationsView()
    func showDevSettingsView()
    
    func showAddMealView(delegate: AddMealDelegate)
    func showMealDetailView(delegate: MealDetailDelegate)

    func showRecipesView()
    func showIngredientsView()

    func showCalendarViewZoom(delegate: CalendarDelegate, transitionId: String?, namespace: Namespace.ID)

}

extension CoreRouter: NutritionRouter { }
