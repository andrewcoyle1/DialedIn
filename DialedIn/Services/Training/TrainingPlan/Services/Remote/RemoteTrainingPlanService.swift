//
//  RemoteTrainingPlanService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

protocol RemoteTrainingPlanService {
    func fetchAllPlans() async throws -> [TrainingPlan]
    func fetchPlan(id: String) async throws -> TrainingPlan
    func createPlan(_ plan: TrainingPlan) async throws
    func updatePlan(_ plan: TrainingPlan) async throws
    func deletePlan(id: String) async throws
}
