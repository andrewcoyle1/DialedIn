//
//  ProfileNutritionDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Foundation

protocol ProfileNutritionDetailInteractor {
    var currentDietPlan: DietPlan? { get }
}

extension CoreInteractor: ProfileNutritionDetailInteractor { }

@Observable
@MainActor
class ProfileNutritionDetailViewModel {
    private let interactor: ProfileNutritionDetailInteractor
    
    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }
    init(
        interactor: ProfileNutritionDetailInteractor
    ) {
        self.interactor = interactor
    }
}
