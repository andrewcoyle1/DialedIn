//
//  DayScheduleSheetView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct DayScheduleSheetViewDelegate {
    let date: Date
    let scheduledWorkouts: [ScheduledWorkout]
    let onStartWorkout: (ScheduledWorkout) -> Void
}

struct DayScheduleSheetView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: DayScheduleSheetViewModel

    let delegate: DayScheduleSheetViewDelegate

    @ViewBuilder var workoutSummaryCardView: (WorkoutSummaryCardViewDelegate) -> AnyView
    @ViewBuilder var todaysWorkoutCardView: (TodaysWorkoutCardViewDelegate) -> AnyView

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
                                WorkoutSummaryCardViewDelegate(
                                    scheduledWorkout: workout, onTap: {
                                        Task {
                                            await viewModel.openCompletedSession(for: workout)
                                        }
                                    }
                                )
                            )
                        } else {
                            todaysWorkoutCardView(
                                TodaysWorkoutCardViewDelegate(
                                    scheduledWorkout: workout, onStart: {
                                        Task {
                                            dismiss()
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
                    dismiss()
                }
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.dayScheduleSheetView(router: router, delegate: DayScheduleSheetViewDelegate(date: Date(), scheduledWorkouts: ScheduledWorkout.mocksWeek1, onStartWorkout: { _ in }))
    }
    .previewEnvironment()
}

#Preview("No Workouts Scheduled") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.dayScheduleSheetView(router: router, delegate: DayScheduleSheetViewDelegate(date: Date(), scheduledWorkouts: [], onStartWorkout: { _ in }))
    }
    .previewEnvironment()
}
