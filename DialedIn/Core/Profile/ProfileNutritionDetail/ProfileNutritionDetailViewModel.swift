//
//  ProfileNutritionDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Foundation

@Observable
@MainActor
class ProfileNutritionDetailViewModel {
    private let nutritionManager: NutritionManager
    
    var currentDietPlan: DietPlan? {
        nutritionManager.currentDietPlan
    }
    init(
        container: DependencyContainer
    ) {
        self.nutritionManager = container.resolve(NutritionManager.self)!
    }
}
