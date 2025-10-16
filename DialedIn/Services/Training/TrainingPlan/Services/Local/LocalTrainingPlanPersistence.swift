//
//  LocalTrainingPlanPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

@MainActor
protocol LocalTrainingPlanPersistence {
    func getCurrentTrainingPlan() -> TrainingPlan?
    func saveTrainingPlan(plan: TrainingPlan) throws
}
