//
//  GoalRowPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class GoalRowPresenter {
    private let interactor: GoalRowInteractor

    init(interactor: GoalRowInteractor) {
        self.interactor = interactor
    }
    
    func removeGoal(goal: TrainingGoal) async {
        try? await interactor.removeGoal(id: goal.id)
    }
}
