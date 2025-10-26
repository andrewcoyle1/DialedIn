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

@Observable
@MainActor
class ProgramGoalsViewModel {
    private let interactor: ProgramGoalsInteractor
    
    private(set) var plan: TrainingPlan
    var showAddGoal: Bool = false
    
    init(
        interactor: ProgramGoalsInteractor,
        plan: TrainingPlan
    ) {
        self.interactor = interactor
        self.plan = plan
    }
}
