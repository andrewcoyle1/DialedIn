//
//  ProfileNutritionPlanViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileNutritionPlanViewModel {
    private let userManager: UserManager
    private let nutritionManager: NutritionManager
   
    var currentDietPlan: DietPlan? {
        nutritionManager.currentDietPlan
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.nutritionManager = container.resolve(NutritionManager.self)!
    }
}
