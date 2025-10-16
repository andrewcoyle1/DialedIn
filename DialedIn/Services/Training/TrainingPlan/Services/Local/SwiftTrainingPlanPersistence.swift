//
//  SwiftTrainingPlanPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

@MainActor
struct SwiftTrainingPlanPersistence: LocalTrainingPlanPersistence {
    private let key = "local_training_plan"
    
    func getCurrentTrainingPlan() -> TrainingPlan? {
        if let data = UserDefaults.standard.data(forKey: key) {
            return try? JSONDecoder().decode(TrainingPlan.self, from: data)
        }
        return nil
    }
    
    func saveTrainingPlan(plan: TrainingPlan) throws {
        let data = try JSONEncoder().encode(plan)
        UserDefaults.standard.set(data, forKey: key)
    }
}
