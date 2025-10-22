//
//  ProgramGoalsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramGoalsViewModel {
    
    private(set) var plan: TrainingPlan
    var showAddGoal: Bool = false
    
    init(
        container: DependencyContainer,
        plan: TrainingPlan
    ) {
        self.plan = plan
    }
}
