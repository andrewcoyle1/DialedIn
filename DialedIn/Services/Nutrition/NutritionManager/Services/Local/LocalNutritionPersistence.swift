//
//  LocalNutritionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

protocol LocalNutritionPersistence {
    func getCurrentDietPlan() -> DietPlan?
    func saveDietPlan(plan: DietPlan) throws
}
