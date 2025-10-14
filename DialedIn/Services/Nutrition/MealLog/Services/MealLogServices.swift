//
//  MealLogServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

protocol MealLogServices {
    var remote: RemoteMealLogService { get }
    var local: LocalMealLogPersistence { get }
}

struct MockMealLogServices: MealLogServices {
    let remote: RemoteMealLogService
    let local: LocalMealLogPersistence
    
    init(mealsByDay: [String: [MealLogModel]] = [:], delay: Double = 0.0, showError: Bool = false) {
        self.remote = MockMealLogService(mealsByDay: mealsByDay, delay: delay, showError: showError)
        self.local = MockMealLogPersistence(mealsByDay: mealsByDay, showError: showError)
    }
}

struct ProductionMealLogServices: MealLogServices {
    let remote: RemoteMealLogService
    let local: LocalMealLogPersistence
    
    init() {
        self.remote = FirebaseMealLogService()
        self.local = SwiftMealLogPersistence()
    }
}
