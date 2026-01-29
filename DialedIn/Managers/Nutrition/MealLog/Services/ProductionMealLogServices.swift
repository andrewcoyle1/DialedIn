//
//  ProductionMealLogServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct ProductionMealLogServices: MealLogServices {
    let remote: RemoteMealLogService
    let local: LocalMealLogPersistence
    
    @MainActor
    init() {
        self.remote = FirebaseMealLogService()
        self.local = SwiftMealLogPersistence()
    }
}
