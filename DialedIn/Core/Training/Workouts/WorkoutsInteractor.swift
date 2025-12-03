//
//  WorkoutsInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol WorkoutsInteractor {
    func trackEvent(event: LoggableEvent)
    func incrementWorkoutTemplateInteraction(id: String) async throws
}

extension CoreInteractor: WorkoutsInteractor { }
