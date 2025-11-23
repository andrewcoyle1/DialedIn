//
//  ProgramGoalsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProgramGoalsInteractor {
    
}

extension CoreInteractor: ProgramGoalsInteractor { }

@MainActor
protocol ProgramGoalsRouter {
    func showAddGoalView(delegate: AddGoalViewDelegate)
    func showDevSettingsView()
}

extension CoreRouter: ProgramGoalsRouter { }

@Observable
@MainActor
class ProgramGoalsViewModel {
    private let interactor: ProgramGoalsInteractor
    private let router: ProgramGoalsRouter

    init(
        interactor: ProgramGoalsInteractor,
        router: ProgramGoalsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onAddGoalPressed(plan: TrainingPlan) {
        router.showAddGoalView(delegate: AddGoalViewDelegate(plan: plan))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
