//
//  ProductionNutritionServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionNutritionServices: NutritionServices {
    let remote: RemoteNutritionService
    let local: LocalNutritionPersistence
    
    @MainActor
    init() {
        self.remote = FirebaseNutritionService()
        self.local = SwiftNutritionPersistence()
    }
}
