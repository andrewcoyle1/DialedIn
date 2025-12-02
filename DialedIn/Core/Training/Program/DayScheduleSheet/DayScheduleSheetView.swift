//
//  DayScheduleSheetView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct DayScheduleDelegate {
    let date: Date
    let scheduledWorkouts: [ScheduledWorkout]
    let onStartWorkout: (ScheduledWorkout) -> Void
}

struct DayScheduleSheetView: View {

    @State var presenter: DayScheduleSheetPresenter

    let delegate: DayScheduleDelegate

    @ViewBuilder var workoutSummaryCardView: (WorkoutSummaryCardDelegate) -> AnyView
    @ViewBuilder var todaysWorkoutCardView: (TodaysWorkoutCardDelegate) -> AnyView

    var body: some View {
        List {
            if delegate.scheduledWorkouts.isEmpty {
                ContentUnavailableView(
                    "No Workouts Scheduled",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("No workouts are scheduled for this day.")
                )
            } else {
                Section {
                    ForEach(delegate.scheduledWorkouts) { workout in
                        if workout.isCompleted {
                            workoutSummaryCardView(
                                WorkoutSummaryCardDelegate(
                                    scheduledWorkout: workout, onTap: {
                                        Task {
                                            await presenter.openCompletedSession(for: workout)
                                        }
                                    }
                                )
                            )
                        } else {
                            todaysWorkoutCardView(
                                TodaysWorkoutCardDelegate(
                                    scheduledWorkout: workout, onStart: {
                                        Task {
                                            presenter.onDismissPressed()
                                            // Small delay to ensure sheet dismissal completes
                                            try? await Task.sleep(nanoseconds: 100_000_000)
                                            delegate.onStartWorkout(workout)
                                        }
                                    }
                                )
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle(delegate.date.formatted(date: .long, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    presenter.onDismissPressed()
                }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.dayScheduleSheetView(router: router, delegate: DayScheduleDelegate(date: Date(), scheduledWorkouts: ScheduledWorkout.mocksWeek1, onStartWorkout: { _ in }))
    }
    .previewEnvironment()
}

#Preview("No Workouts Scheduled") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.dayScheduleSheetView(router: router, delegate: DayScheduleDelegate(date: Date(), scheduledWorkouts: [], onStartWorkout: { _ in }))
    }
    .previewEnvironment()
}
