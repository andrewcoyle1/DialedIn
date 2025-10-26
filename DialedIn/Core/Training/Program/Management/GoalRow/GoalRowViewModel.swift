//
//  GoalRowViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol GoalRowInteractor {
    func removeGoal(id: String) async throws
}

extension CoreInteractor: GoalRowInteractor { }

@Observable
@MainActor
class GoalRowViewModel {
    private let interactor: GoalRowInteractor
    
    let goal: TrainingGoal
    let plan: TrainingPlan
    
    init(
        interactor: GoalRowInteractor,
        goal: TrainingGoal,
        plan: TrainingPlan
    ) {
        self.interactor = interactor
        self.goal = goal
        self.plan = plan
    }
    
    func removeGoal() async {
        try? await interactor.removeGoal(id: goal.id)
    }
}
