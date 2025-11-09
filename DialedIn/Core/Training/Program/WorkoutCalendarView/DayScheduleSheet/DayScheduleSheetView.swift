//
//  DayScheduleSheetView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct DayScheduleSheetView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: DayScheduleSheetViewModel

    var body: some View {
        NavigationStack {
            List {
                if viewModel.scheduledWorkouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Scheduled",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No workouts are scheduled for this day.")
                    )
                } else {
                    Section {
                        ForEach(viewModel.scheduledWorkouts) { workout in
                            if workout.isCompleted {
                                WorkoutSummaryCardView(
                                    viewModel: WorkoutSummaryCardViewModel(
                                        interactor: CoreInteractor(container: container),
                                        scheduledWorkout: workout,
                                        onTap: {
                                            Task {
                                                await viewModel.openCompletedSession(for: workout)
                                            }
                                        }
                                    )
                                )
                            } else {
                                TodaysWorkoutCardView(
                                    viewModel: TodaysWorkoutCardViewModel(interactor: CoreInteractor(container: container),
                                    scheduledWorkout: workout,
                                    onStart: {
                                        Task {
                                            dismiss()
                                            // Small delay to ensure sheet dismissal completes
                                            try? await Task.sleep(nanoseconds: 100_000_000)
                                            do {
                                                try await viewModel.onStartWorkout(workout)
                                            } catch {
                                                viewModel.showAlert = AnyAppAlert(error: error)
                                            }
                                        }
                                    })
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $viewModel.sessionToShow) { session in
                builder.workoutSessionDetailView(session: session)
            }
            .showCustomAlert(alert: $viewModel.showAlert)
        }
    }
}

#Preview {
    DayScheduleSheetView(
        viewModel: DayScheduleSheetViewModel(
            interactor: CoreInteractor(container: DevPreview.shared.container),
            date: Date(),
            scheduledWorkouts: ScheduledWorkout.mocksWeek1,
            onStartWorkout: { _ in }
        )
    )
    .previewEnvironment()
}

#Preview("No Workouts Scheduled") {
    DayScheduleSheetView(
        viewModel: DayScheduleSheetViewModel(
            interactor: CoreInteractor(container: DevPreview.shared.container),
            date: Date(),
            scheduledWorkouts: [],
            onStartWorkout: { _ in }
        )
    )
    .previewEnvironment()
}
