//
//  ExercisesInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

protocol ExercisesInteractor {
    var currentUser: UserModel? { get }
    func incrementExerciseTemplateInteraction(id: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ExercisesInteractor { }
