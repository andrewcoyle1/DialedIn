//
//  ProfileNutritionPlanViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileNutritionPlanInteractor {
    var currentDietPlan: DietPlan? { get }
}

extension CoreInteractor: ProfileNutritionPlanInteractor { }

@Observable
@MainActor
class ProfileNutritionPlanViewModel {
    private let interactor: ProfileNutritionPlanInteractor
   
    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }
    
    init(
        interactor: ProfileNutritionPlanInteractor
    ) {
        self.interactor = interactor
    }
}
