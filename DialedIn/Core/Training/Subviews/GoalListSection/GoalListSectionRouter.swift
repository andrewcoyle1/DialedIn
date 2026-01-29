//
//  GoalListSectionRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

@MainActor
protocol GoalListSectionRouter {
    func showAddGoalView(delegate: AddGoalDelegate)

}

extension CoreRouter: GoalListSectionRouter { }
