//
//  WorkoutSummaryCardView.swift
//  DialedIn
//
//  Shows a summary of a completed workout session
//

import SwiftUI
import SwiftfulRouting

struct WorkoutSummaryCardView: View {
    @State var presenter: WorkoutSummaryCardPresenter

    let delegate: WorkoutSummaryCardDelegate

    var body: some View {
        Button {
            delegate.onTap()
        } label: {
            HStack(spacing: 16) {
                // Status indicator
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                
                // Workout info
                VStack(alignment: .leading, spacing: 8) {
                    Text(presenter.session?.name ?? delegate.scheduledWorkout.workoutName ?? "Workout")
                        .font(.subheadline)
                    
                        summaryMetrics
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .tappableBackground()
        }
        .buttonStyle(.plain)
        .task {
            await presenter.loadSession(scheduledWorkout: delegate.scheduledWorkout)
        }
    }
    
    private var summaryMetrics: some View {
        HStack(spacing: 16) {
            if let session = presenter.session {
                // Date
                MetricView(
                    label: "date",
                    value: session.dateModified.formatted(.dateTime.day().month()),
                    icon: "calendar"
                )

                // Duration
                if let endedAt = session.endedAt {
                    let duration = endedAt.timeIntervalSince(session.dateCreated)
                    MetricView(
                        label: "Duration",
                        value: presenter.formatDuration(duration),
                        icon: "clock",
                        isLoading: presenter.isLoading
                    )
                } else {
                    MetricView(
                        label: "Duration",
                        value: "—",
                        icon: "clock",
                        isLoading: presenter.isLoading
                    )
                }

                // Sets completed
                let completedSetsCount = session.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
                MetricView(
                    label: "Sets",
                    value: "\(completedSetsCount)",
                    icon: "list.bullet"
                )

                // Volume (if applicable)
                let volume = presenter.calculateTotalVolume(session: session)
                if volume > 0 {
                    MetricView(
                        label: "Volume",
                        value: String(format: "%.0f kg", volume),
                        icon: "scalemass"
                    )
                }

                // Exercises
                MetricView(
                    label: "Exercises",
                    value: "\(session.exercises.count)",
                    icon: "figure.strengthtraining.traditional"
                )
            } else {
                // Fallback placeholders if session isn't loaded yet
                MetricView(label: "date", value: "xxxxxxxxx", icon: "calendar", isLoading: true)
                MetricView(label: "Duration", value: "xxxxxxxxx", icon: "clock", isLoading: true)
                MetricView(label: "Sets", value: "0", icon: "list.bullet", isLoading: true)
                MetricView(label: "Exercises", value: "0", icon: "figure.strengthtraining.traditional", isLoading: true)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
struct MetricView: View {
    let label: String
    let value: String
    let icon: String
    var isLoading: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            if isLoading {
                Text(value)
                    .fontWeight(.medium)
                    .redacted(reason: .placeholder)
            } else {
                Text(value)
                    .fontWeight(.medium)
            }
        }
    }
}

extension CoreBuilder {
    func workoutSummaryCardView(router: AnyRouter, delegate: WorkoutSummaryCardDelegate) -> some View {
        WorkoutSummaryCardView(
            presenter: WorkoutSummaryCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

#Preview("Completed Workout") {
    let scheduledWorkout = ScheduledWorkout(
        workoutTemplateId: "test",
        workoutName: "Upper Body Strength",
        dayOfWeek: 2,
        scheduledDate: Date(),
        completedSessionId: "session-1",
        isCompleted: true
    )

    let builder = CoreBuilder(container: DevPreview.shared.container())
    return RouterView { router in
        List {
            builder.workoutSummaryCardView(
                router: router,
                delegate: WorkoutSummaryCardDelegate(
                    scheduledWorkout: scheduledWorkout,
                    onTap: {
                        print("Row tapped.")
                    }
                )
            )
        }
    }
    .previewEnvironment()
}

#Preview("Loading State") {
    let scheduledWorkout = ScheduledWorkout(
        workoutTemplateId: "test",
        workoutName: "Upper Body Strength",
        dayOfWeek: 2,
        scheduledDate: Date(),
        completedSessionId: "session-1",
        isCompleted: true
    )
    
    let container = DevPreview.shared.container()
    container.register(WorkoutSessionManager.self, service: WorkoutSessionManager(services: MockWorkoutSessionServices(delay: 10)))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        List {
            builder.workoutSummaryCardView(
                router: router,
                delegate: WorkoutSummaryCardDelegate(
                    scheduledWorkout: scheduledWorkout,
                    onTap: {
                        print("Row tapped.")
                    }
                )
            )
        }
    }
    .previewEnvironment()
}
