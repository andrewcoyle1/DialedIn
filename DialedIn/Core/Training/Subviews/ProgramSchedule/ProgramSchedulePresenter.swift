//
//  ProgramSchedulePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import Foundation

@Observable
@MainActor
class ProgramSchedulePresenter {
    private let interactor: ProgramScheduleInteractor
    private let router: ProgramScheduleRouter

    init(
        interactor: ProgramScheduleInteractor,
        router: ProgramScheduleRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func weeks(for plan: TrainingPlan) -> [TrainingWeek] {
        plan.weeks.sorted(by: { $0.weekNumber < $1.weekNumber })
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
