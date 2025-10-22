//
//  ProgramManagementViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramManagementViewModel {
    private let authManager: AuthManager
    private let trainingPlanManager: TrainingPlanManager
    private let programTemplateManager: ProgramTemplateManager
    
    private(set) var isLoading = false

    var showCreateSheet = false
    var editingPlan: TrainingPlan?
    var planToDelete: TrainingPlan?
    var showDeleteAlert: AnyAppAlert?
    
    var activePlan: TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }
    
    var trainingPlans: [TrainingPlan] {
        trainingPlanManager.allPlans
    }
    
    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.programTemplateManager = container.resolve(ProgramTemplateManager.self)!
    }
    
    func setActivePlan(_ plan: TrainingPlan) async {
        isLoading = true
        defer { isLoading = false }
        
        trainingPlanManager.setActivePlan(plan)
    }
    
    func deletePlan(_ plan: TrainingPlan) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await trainingPlanManager.deletePlan(id: plan.planId)
        } catch {
            print("Error deleting plan: \(error)")
        }
    }
}
