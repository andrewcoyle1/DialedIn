//
//  GoalListSectionPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI

@Observable
@MainActor
class GoalListSectionPresenter {
    private let interactor: GoalListSectionInteractor
    private let router: GoalListSectionRouter
    
    var isExpanded: Bool = false
    
    var currentTrainingPlan: TrainingPlan? {
        interactor.currentTrainingPlan
    }
    
    init(
        interactor: GoalListSectionInteractor,
        router: GoalListSectionRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onExpansionToggled() {
        withAnimation(.easeInOut) {
            isExpanded.toggle()
        }
    }
    
    func onAddGoalPressed() {
        guard let plan = currentTrainingPlan else { return }
        router.showAddGoalView(delegate: AddGoalDelegate(plan: plan))
    }
}
