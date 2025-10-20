//
//  RemoteNutritionService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

protocol NutritionServices {
    var remote: RemoteNutritionService { get }
    var local: LocalNutritionPersistence { get }
}

struct MockNutritionServices: NutritionServices {
    let remote: RemoteNutritionService
    let local: LocalNutritionPersistence
    
    init(plan: DietPlan? = .mock, delay: Double = 0, showError: Bool = false) {
        self.remote = MockNutritionService(plan: plan, delay: delay, showError: showError)
        self.local = MockNutritionPersistence(plan: plan, delay: delay, showError: showError)
    }
}

struct ProductionNutritionServices: NutritionServices {
    let remote: RemoteNutritionService
    let local: LocalNutritionPersistence
    
    init() {
        self.remote = FirebaseNutritionService()
        self.local = SwiftNutritionPersistence()
    }
}
