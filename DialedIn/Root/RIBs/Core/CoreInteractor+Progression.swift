//
//  CoreInteractor+Progression.swift
//  DialedIn
//
//  Smart progression's two entry points: the prefill a session is built with, and the
//  suggestions the tracker screen keeps so it can explain itself and adjust live.
//

import Foundation

extension CoreInteractor {

    /// How the working sets of a session started from `template` should be filled in.
    ///
    /// `.smartProgression` runs the engine per exercise; an exercise with no history yields
    /// `.noHistory` and falls back to the previous session's values, which is what the user would
    /// have seen anyway.
    func sessionPrefill(
        for template: WorkoutTemplateModel,
        authorId: String,
        trainingProgramId: String?,
        unitPreferences: [String: ExerciseUnitPreference]
    ) async -> SessionPrefill {
        switch workoutSettings.smartProgressionInitialLogFill {
        case .previousValues:
            return .previousValues
        case .empty:
            return .empty
        case .smartProgression:
            let contexts = template.exercises.map { templateExercise in
                ProgressionPlanner.ExerciseContext(
                    templateExercise: templateExercise,
                    preferredWeightUnit: unitPreferences[templateExercise.exercise.id]?.weightUnit
                )
            }
            let history = await progressionHistory(
                templateId: template.id,
                authorId: authorId,
                trainingProgramId: trainingProgramId
            )
            return .suggestions(
                ProgressionPlanner.suggestions(
                    for: contexts,
                    history: history,
                    adjustmentMode: workoutSettings.smartProgressionAdjustmentMode,
                    gymProfile: workoutGymProfile
                )
            )
        }
    }

    /// The suggestions for a session already under way, so the tracker can show why a set reads
    /// the way it does and re-suggest the sets still to come.
    func progressionSuggestions(
        for session: WorkoutSessionModel,
        gymProfile: GymProfileModel?
    ) async -> [String: ProgressionSuggestion] {
        guard let templateId = session.workoutTemplateId, let authorId = currentUser?.userId else { return [:] }

        let contexts = session.exercises.map { exercise in
            ProgressionPlanner.ExerciseContext(
                sessionExercise: exercise,
                exercise: allExercises.first(where: { $0.id == exercise.templateId }),
                preferredWeightUnit: getPreference(templateId: exercise.templateId).weightUnit
            )
        }
        let history = await progressionHistory(
            templateId: templateId,
            authorId: authorId,
            trainingProgramId: session.trainingProgramId
        )

        return ProgressionPlanner.suggestions(
            for: contexts,
            history: history,
            adjustmentMode: workoutSettings.smartProgressionAdjustmentMode,
            gymProfile: gymProfile ?? workoutGymProfile
        )
    }

    /// The sessions the engine reasons from, honouring `previousWorkoutReference` the same way
    /// the tracker's previous-values column does. A workout logged outside a program has no
    /// program to be within, so it keeps the unrestricted lookup.
    private func progressionHistory(
        templateId: String,
        authorId: String,
        trainingProgramId: String?
    ) async -> [WorkoutSessionModel] {
        let programId: String?
        switch workoutSettings.previousWorkoutReference {
        case .anyWorkout:        programId = nil
        case .workoutsInProgram: programId = trainingProgramId
        }

        return (try? await getLastCompletedSessionsForTemplate(
            templateId: templateId,
            authorId: authorId,
            inTrainingProgramId: programId,
            limit: 3
        )) ?? []
    }
}
