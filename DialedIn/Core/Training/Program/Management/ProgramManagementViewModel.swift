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

@MainActor
protocol ProgramManagementRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: ProgramManagementRouter { }

@Observable
@MainActor
class ProgramManagementViewModel {
    private let interactor: ProgramManagementInteractor
    private let router: ProgramManagementRouter

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
        interactor: ProgramManagementInteractor,
        router: ProgramManagementRouter
    ) {
        self.interactor = interactor
        self.router = router
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

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}
