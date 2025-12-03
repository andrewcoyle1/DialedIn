//
//  WorkoutPickerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

protocol WorkoutPickerInteractor {
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: WorkoutPickerInteractor {
}
