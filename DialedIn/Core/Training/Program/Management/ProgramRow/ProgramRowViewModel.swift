//
//  ProgramRowViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol ProgramRowInteractor {
    
}

extension CoreInteractor: ProgramRowInteractor { }

@Observable
@MainActor
class ProgramRowViewModel {
    private let interactor: ProgramRowInteractor

    init(interactor: ProgramRowInteractor) {
        self.interactor = interactor
    }
    
    func programDuration(plan: TrainingPlan) -> Int {
        guard let endDate = plan.endDate else { return 0 }
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: plan.startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }
    
    func totalWorkouts(plan: TrainingPlan) -> Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.count
    }
}
