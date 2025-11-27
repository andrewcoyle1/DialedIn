//
//  GoalRowInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol GoalRowInteractor {
    func removeGoal(id: String) async throws
}

extension CoreInteractor: GoalRowInteractor { }
