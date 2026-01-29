//
//  MockMealLogServices.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

struct MockMealLogServices: MealLogServices {
    let remote: RemoteMealLogService
    let local: LocalMealLogPersistence
    
    init(mealsByDay: [String: [MealLogModel]] = [:], delay: Double = 0.0, showError: Bool = false) {
        self.remote = MockMealLogService(mealsByDay: mealsByDay, delay: delay, showError: showError)
        self.local = MockMealLogPersistence(mealsByDay: mealsByDay, showError: showError)
    }
}
