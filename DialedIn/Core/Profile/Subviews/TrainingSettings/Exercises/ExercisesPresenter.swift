//
//  ExercisesPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExercisesPresenter {
    private let interactor: ExercisesInteractor
    private let router: ExercisesRouter
    
    init(
        interactor: ExercisesInteractor,
        router: ExercisesRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onExercisePressed(exercise: ExerciseModel) {
        // Only increment click count for non-system exercises
        // System exercises (IDs starting with "system-") are read-only
        if !exercise.id.hasPrefix("system-") {
            Task {
                interactor.trackEvent(event: ExercisesViewEvents.incrementExerciseStart)
                do {
                    try await interactor.incrementExerciseTemplateInteraction(id: exercise.id)
                    interactor.trackEvent(event: ExercisesViewEvents.incrementExerciseSuccess)
                } catch {
                    interactor.trackEvent(event: ExercisesViewEvents.incrementExerciseFail(error: error))
                }
            }
        }

        router.showExerciseTemplateDetailView(delegate: ExerciseTemplateDetailDelegate(exerciseTemplate: exercise))
    }

    enum ExercisesViewEvents: LoggableEvent {
        case incrementExerciseStart
        case incrementExerciseSuccess
        case incrementExerciseFail(error: Error)

        var eventName: String {
            switch self {
            case .incrementExerciseStart:              return "ExercisesView_IncrementExercise_Start"
            case .incrementExerciseSuccess:            return "ExercisesView_IncrementExercise_Success"
            case .incrementExerciseFail:               return "ExercisesView_IncrementExercise_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .incrementExerciseFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .incrementExerciseFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
