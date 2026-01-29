//
//  MockNutritionServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockNutritionServices: NutritionServices {
    let remote: RemoteNutritionService
    let local: LocalNutritionPersistence
    
    init(plan: DietPlan? = .mock, delay: Double = 0, showError: Bool = false) {
        self.remote = MockNutritionService(plan: plan, delay: delay, showError: showError)
        self.local = MockNutritionPersistence(plan: plan, delay: delay, showError: showError)
    }
}
