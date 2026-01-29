//
//  LocalTrainingPlanPersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

protocol LocalTrainingPlanPersistence {
    func getCurrentTrainingPlan() -> TrainingPlan?
    func getAllPlans() -> [TrainingPlan]
    func getPlan(id: String) -> TrainingPlan?
    func savePlan(_ plan: TrainingPlan) throws
    func deletePlan(id: String) throws
    
    // Legacy method for backwards compatibility
    func saveTrainingPlan(plan: TrainingPlan) throws
}
