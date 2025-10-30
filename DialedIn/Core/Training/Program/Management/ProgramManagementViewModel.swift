//
//  ProgramManagementViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProgramManagementInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    var allPlans: [TrainingPlan] { get }
    func setActivePlan(_ plan: TrainingPlan)
    func deletePlan(id: String) async throws
}

extension CoreInteractor: ProgramManagementInteractor { }

@Observable
@MainActor
class ProgramManagementViewModel {
    private let interactor: ProgramManagementInteractor
    
    private(set) var isLoading = false

    var showCreateSheet = false
    var editingPlan: TrainingPlan?
    var planToDelete: TrainingPlan?
    var showDeleteAlert: AnyAppAlert?
    
    var activePlan: TrainingPlan? {
        interactor.currentTrainingPlan
    }
    
    var trainingPlans: [TrainingPlan] {
        interactor.allPlans
    }
    
    init(
        interactor: ProgramManagementInteractor
    ) {
        self.interactor = interactor
    }
    
    func setActivePlan(_ plan: TrainingPlan) async {
        isLoading = true
        defer { isLoading = false }
        
        interactor.setActivePlan(plan)
    }
    
    func deletePlan(_ plan: TrainingPlan) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await interactor.deletePlan(id: plan.planId)
        } catch {
            print("Error deleting plan: \(error)")
        }
    }
}
