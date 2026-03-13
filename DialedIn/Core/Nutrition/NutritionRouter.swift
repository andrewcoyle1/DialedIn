//
//  NutritionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol NutritionRouter: GlobalRouter {
    #if DEV || MOCK
    func showDevSettingsView()
    #endif

    func showAddMealView(delegate: AddMealDelegate)
    func showMealDetailView(delegate: MealDetailDelegate)
    func showMealItemAmountViewView(delegate: MealItemAmountViewDelegate)
    func showProfileView()
    
    func showTimelineActionsView(delegate: TimelineActionsDelegate)
    func showFoodLogSettingsView(delegate: FoodLogSettingsDelegate)
    func showNutritionOverviewView(delegate: NutritionOverviewDelegate)
}

extension CoreRouter: NutritionRouter { }
