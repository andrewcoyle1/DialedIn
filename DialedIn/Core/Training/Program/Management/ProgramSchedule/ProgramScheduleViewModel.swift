//
//  ProgramScheduleViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import Foundation

protocol ProgramScheduleInteractor {
    
}

extension CoreInteractor: ProgramScheduleInteractor { }

@Observable
@MainActor
class ProgramScheduleViewModel {
    private let interactor: ProgramScheduleInteractor
    
    init(
        interactor: ProgramScheduleInteractor
    ) {
        self.interactor = interactor
    }
    
    func weeks(for plan: TrainingPlan) -> [TrainingWeek] {
        plan.weeks.sorted(by: { $0.weekNumber < $1.weekNumber })
    }
}
