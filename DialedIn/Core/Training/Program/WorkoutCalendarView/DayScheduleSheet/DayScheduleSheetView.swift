//
//  DayScheduleSheetView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct DayScheduleSheetViewDelegate {
    let date: Date
    let scheduledWorkouts: [ScheduledWorkout]
    let onStartWorkout: (ScheduledWorkout) -> Void
}

struct DayScheduleSheetView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: DayScheduleSheetViewModel

    let delegate: DayScheduleSheetViewDelegate

    var body: some View {
        NavigationStack {
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
                                builder.workoutSummaryCardView(
                                    delegate: WorkoutSummaryCardViewDelegate(
                                        scheduledWorkout: workout, onTap: {
                                            Task {
                                                await viewModel.openCompletedSession(for: workout)
                                            }
                                        }
                                    )
                                )
                            } else {
                                builder.todaysWorkoutCardView(
                                    delegate: TodaysWorkoutCardViewDelegate(
                                        scheduledWorkout: workout, onStart: {
                                            Task {
                                                dismiss()
                                                // Small delay to ensure sheet dismissal completes
                                                try? await Task.sleep(nanoseconds: 100_000_000)
                                                do {
                                                    try await delegate.onStartWorkout(workout)
                                                } catch {
                                                    viewModel.showAlert = AnyAppAlert(error: error)
                                                }
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
            .sheet(item: $viewModel.sessionToShow) { session in
                let delegate = WorkoutSessionDetailViewDelegate(workoutSession: session)
                builder.workoutSessionDetailView(delegate: delegate)
            }
            .showCustomAlert(alert: $viewModel.showAlert)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.dayScheduleSheetView(delegate: DayScheduleSheetViewDelegate(date: Date(), scheduledWorkouts: ScheduledWorkout.mocksWeek1, onStartWorkout: { _ in }))
    .previewEnvironment()
}

#Preview("No Workouts Scheduled") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.dayScheduleSheetView(delegate: DayScheduleSheetViewDelegate(date: Date(), scheduledWorkouts: [], onStartWorkout: { _ in }))
    .previewEnvironment()
}
