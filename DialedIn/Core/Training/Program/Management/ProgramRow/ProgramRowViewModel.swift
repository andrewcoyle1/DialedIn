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
    let plan: TrainingPlan
    let isActive: Bool
    let onActivate: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    init(
        interactor: ProgramRowInteractor,
        plan: TrainingPlan,
        isActive: Bool,
        onActivate: @escaping () -> Void = { },
        onEdit: @escaping () -> Void = { },
        onDelete: @escaping () -> Void = { }
    ) {
        self.interactor = interactor
        self.plan = plan
        self.isActive = isActive
        self.onActivate = onActivate
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var programDuration: Int {
        guard let endDate = plan.endDate else { return 0 }
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: plan.startDate, to: endDate).weekOfYear ?? 0
        return max(weeks, 0)
    }
    
    var totalWorkouts: Int {
        plan.weeks.flatMap { $0.scheduledWorkouts }.count
    }
}
