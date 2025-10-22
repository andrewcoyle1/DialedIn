//
//  GoalRowViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class GoalRowViewModel {
    private let trainingPlanManager: TrainingPlanManager
    
    let goal: TrainingGoal
    let plan: TrainingPlan
    
    init(
        container: DependencyContainer,
        goal: TrainingGoal,
        plan: TrainingPlan
    ) {
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.goal = goal
        self.plan = plan
    }
    
    func removeGoal() async {
        try? await trainingPlanManager.removeGoal(id: goal.id)
    }
}
