//
//  ProgramManagementInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol ProgramManagementInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    var allPlans: [TrainingPlan] { get }
    func setActivePlan(_ plan: TrainingPlan)
    func deletePlan(id: String) async throws
}

extension CoreInteractor: ProgramManagementInteractor { }
