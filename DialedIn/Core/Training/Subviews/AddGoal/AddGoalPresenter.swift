//
//  AddGoalPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class AddGoalPresenter {
    private let interactor: AddGoalInteractor
    private let router: AddGoalRouter

    var selectedType: GoalType = .consistency
    var targetValue: Double = 12
    var hasTargetDate = true
    var targetDate = Date()
    private(set) var isSaving = false
    private(set) var plan: TrainingPlan?
    
    init(
        interactor: AddGoalInteractor,
        router: AddGoalRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func addTrainingPlan(_ plan: TrainingPlan) {
        self.plan = plan
    }
    
    func addGoal() async {
        isSaving = true
        defer { isSaving = false }
        
        let goal = TrainingGoal(
            type: selectedType,
            targetValue: targetValue,
            currentValue: 0,
            targetDate: hasTargetDate ? targetDate : nil
        )
        
        do {
            try await interactor.addGoal(goal)
            router.dismissScreen()
        } catch {
            print("Error adding goal: \(error)")
        }
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
