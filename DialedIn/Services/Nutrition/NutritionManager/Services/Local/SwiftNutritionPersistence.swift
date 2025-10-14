//
//  SwiftNutritionPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

@MainActor
struct SwiftNutritionPersistence: LocalNutritionPersistence {
    private let key = "local_diet_plan"
    
    func getCurrentDietPlan() -> DietPlan? {
        if let data = UserDefaults.standard.data(forKey: key) {
            return try? JSONDecoder().decode(DietPlan.self, from: data)
        }
        return nil
    }
    
    func saveDietPlan(plan: DietPlan) throws {
        let data = try JSONEncoder().encode(plan)
        UserDefaults.standard.set(data, forKey: key)
    }
}
