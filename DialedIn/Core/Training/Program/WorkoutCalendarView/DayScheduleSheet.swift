//
//  DayScheduleSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

// MARK: - Day Schedule Sheet

struct DayScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    
    let date: Date
    let scheduledWorkouts: [ScheduledWorkout]
    let onStartWorkout: (ScheduledWorkout) async throws -> Void
    @State private var sessionToShow: WorkoutSessionModel?
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                if scheduledWorkouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Scheduled",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No workouts are scheduled for this day.")
                    )
                } else {
                    Section {
                        ForEach(scheduledWorkouts) { workout in
                            if workout.isCompleted {
                                WorkoutSummaryCard(
                                    scheduledWorkout: workout,
                                    onTap: {
                                        Task {
                                            await openCompletedSession(for: workout)
                                        }
                                    }
                                )
                            } else {
                                TodaysWorkoutCard(
                                    scheduledWorkout: workout,
                                    onStart: {
                                        Task {
                                            dismiss()
                                            // Small delay to ensure sheet dismissal completes
                                            try? await Task.sleep(nanoseconds: 100_000_000)
                                            do {
                                                try await onStartWorkout(workout)
                                            } catch {
                                                showAlert = AnyAppAlert(error: error)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle(date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $sessionToShow) { session in
                WorkoutSessionDetailView(session: session)
            }
            .showCustomAlert(alert: $showAlert)
        }
    }

    private func openCompletedSession(for workout: ScheduledWorkout) async {
        guard let sessionId = workout.completedSessionId else { return }
        do {
            let session = try await workoutSessionManager.getWorkoutSession(id: sessionId)
            await MainActor.run {
                sessionToShow = session
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}

#Preview {
    DayScheduleSheet(
        date: Date(),
        scheduledWorkouts: ScheduledWorkout.mocksWeek1,
        onStartWorkout: { _ in }
    )
    .previewEnvironment()
}

#Preview("No Workouts Scheduled") {
    DayScheduleSheet(
        date: Date(),
        scheduledWorkouts: [],
        onStartWorkout: { _ in }
    )
    .previewEnvironment()
}
