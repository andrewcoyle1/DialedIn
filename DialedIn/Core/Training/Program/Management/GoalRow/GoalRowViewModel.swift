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

    init(interactor: GoalRowInteractor) {
        self.interactor = interactor
    }
    
    func removeGoal(goal: TrainingGoal) async {
        try? await interactor.removeGoal(id: goal.id)
    }
}
