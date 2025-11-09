//
//  CoreBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/11/2025.
//

import SwiftUI

@Observable
@MainActor
class CoreBuilder {

    let interactor: CoreInteractor

    init(container: DependencyContainer) {
        interactor = CoreInteractor(container: container)
    }

    func exerciseTemplateDetailView(exercise: ExerciseTemplateModel) -> some View {
        ExerciseTemplateDetailView(
            viewModel: ExerciseTemplateDetailViewModel(interactor: interactor),
            exerciseTemplate: exercise
        )
    }

    func workoutTemplateDetailView(workout: WorkoutTemplateModel) -> some View {
        WorkoutTemplateDetailView(
            viewModel: WorkoutTemplateDetailViewModel(interactor: interactor),
            workoutTemplate: workout
        )
    }

    func workoutSessionDetailView(session: WorkoutSessionModel) -> some View {
        WorkoutSessionDetailView(
            viewModel: WorkoutSessionDetailViewModel(interactor: interactor),
            workoutSession: session
        )
    }

    func programView(onSessionSelectionChangeded: @escaping (WorkoutSessionModel?) -> Void, onWorkoutStartRequested: @escaping (WorkoutTemplateModel, ScheduledWorkout?) -> Void, onActiveSheetChanged: @escaping (ActiveSheet?) -> Void) -> some View {
        ProgramView(
            viewModel: ProgramViewModel(
                interactor: interactor,
                onSessionSelectionChanged: onSessionSelectionChangeded,
                onWorkoutStartRequested: onWorkoutStartRequested,
                onActiveSheetChanged: onActiveSheetChanged
            )
        )
    }

    func devSettingsView() -> some View {
        DevSettingsView(viewModel: DevSettingsViewModel(interactor: interactor))
    }

    func workoutStartView(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout?) -> some View {
        WorkoutStartView(
            viewModel: WorkoutStartViewModel(
                interactor: interactor
            ),
            template: template,
            scheduledWorkout: scheduledWorkout
        )
    }

    func workoutsView(onWorkoutSelectionChanged: ((WorkoutTemplateModel) -> Void)? = nil) -> some View {
        WorkoutsView(
            viewModel: WorkoutsViewModel(
                interactor: interactor,
                onWorkoutSelectionChanged: onWorkoutSelectionChanged
            )
        )
    }

    func workoutHistoryView(onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil) -> some View {
        WorkoutHistoryView(
            viewModel: WorkoutHistoryViewModel(
                interactor: interactor,
                onSessionSelectionChanged: onSessionSelectionChanged
            )
        )
    }

    func createWorkoutView() -> some View {
        CreateWorkoutView(viewModel: CreateWorkoutViewModel(interactor: interactor))
    }

    func addExerciseModalView(selectedExercises: Binding<[ExerciseTemplateModel]>) -> some View {
        AddExerciseModalView(
            viewModel: AddExerciseModalViewModel(
                interactor: interactor
            ),
            selectedExercises: selectedExercises
        )

    }

    func exercisesView(onExerciseSelectionChanged: ((ExerciseTemplateModel) -> Void)? = nil) -> some View {
        ExercisesView(
            viewModel: ExercisesViewModel(
                interactor: interactor,
                onExerciseSelectionChanged: onExerciseSelectionChanged
            )
        )
    }

    func programManagementView(path: Binding<[TabBarPathOption]>) -> some View {
        ProgramManagementView(
            viewModel: ProgramManagementViewModel(
                interactor: interactor
            ),
            path: path
        )
    }

    func trainingView(path: Binding<[TabBarPathOption]>) -> some View {
        TrainingView(
            viewModel: TrainingViewModel(
                interactor: interactor
            ),
            path: path
        )
    }

    func progressDashboardView() -> some View {
        ProgressDashboardView(
            viewModel: ProgressDashboardViewModel(interactor: interactor)
        )
    }

    func strengthProgressView() -> some View {
        StrengthProgressView(
            viewModel: StrengthProgressViewModel(interactor: interactor)
        )
    }

    func workoutHeatmapView() -> some View {
        WorkoutHeatmapView(
            viewModel: WorkoutHeatmapViewModel(interactor: interactor)
        )
    }

    func notificationsView() -> some View {
        NotificationsView(
            viewModel: NotificationsViewModel(interactor: interactor)
        )
    }
}
