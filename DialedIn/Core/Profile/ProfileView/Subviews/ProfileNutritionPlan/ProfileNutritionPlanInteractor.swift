//
//  ProfileNutritionPlanInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProfileNutritionPlanInteractor {
    var currentDietPlan: DietPlan? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileNutritionPlanInteractor { }
