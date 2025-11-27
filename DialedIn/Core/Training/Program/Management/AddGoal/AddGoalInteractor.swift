//
//  AddGoalInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AddGoalInteractor {
    func addGoal(_ goal: TrainingGoal) async throws
}

extension CoreInteractor: AddGoalInteractor { }
