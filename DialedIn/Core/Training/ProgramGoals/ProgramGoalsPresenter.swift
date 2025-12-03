//
//  ProgramGoalsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramGoalsPresenter {
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
        router.showAddGoalView(delegate: AddGoalDelegate(plan: plan))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
