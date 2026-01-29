//
//  RemoteTrainingPlanService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

protocol RemoteTrainingPlanService {
    func fetchAllPlans(userId: String) async throws -> [TrainingPlan]
    func fetchPlan(id: String, userId: String) async throws -> TrainingPlan
    func createPlan(_ plan: TrainingPlan) async throws
    func updatePlan(_ plan: TrainingPlan) async throws
    func deletePlan(id: String) async throws
    
    // Real-time listener
    func addPlansListener(userId: String, onChange: @escaping ([TrainingPlan]) -> Void) -> (() -> Void)
}
