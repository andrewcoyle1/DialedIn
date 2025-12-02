//
//  GoalListSectionInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

protocol GoalListSectionInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
}

extension CoreInteractor: GoalListSectionInteractor { }
