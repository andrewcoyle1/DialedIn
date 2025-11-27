//
//  ProgramManagementPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramManagementPresenter {
    private let interactor: ProgramManagementInteractor
    private let router: ProgramManagementRouter

    private(set) var isLoading = false

    var showCreateSheet = false
    var editingPlan: TrainingPlan?
    var planToDelete: TrainingPlan?

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

    func showDeleteAlert(activePlan: TrainingPlan) {
        router.showAlert(
            title: "Delete Program",
            subtitle: "Are you sure you want to delete your active program '\(activePlan.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.",
            buttons: {
                AnyView(
                    Group {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            Task {
                                await self.deletePlan(activePlan)
                            }
                        }
                    }
                )
            }
        )
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
