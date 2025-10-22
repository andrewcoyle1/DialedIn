//
//  WorkoutSummaryCardView.swift
//  DialedIn
//
//  Shows a summary of a completed workout session
//

import SwiftUI

struct WorkoutSummaryCardView: View {
    @State var viewModel: WorkoutSummaryCardViewModel
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    
    var body: some View {
        Button {
            viewModel.onTap()
        } label: {
            HStack(spacing: 16) {
                // Status indicator
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
                
                // Workout info
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.session?.name ?? viewModel.scheduledWorkout.workoutName ?? "Workout")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else if let session = viewModel.session {
                        summaryMetrics(for: session)
                    }
                }
                
                Spacer()
                
                // Navigation indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .task {
            await viewModel.loadSession()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    @ViewBuilder
    private func summaryMetrics(for session: WorkoutSessionModel) -> some View {
        HStack(spacing: 16) {
            // Duration
            if let endedAt = session.endedAt {
                let duration = endedAt.timeIntervalSince(session.dateCreated)
                metricView(
                    label: "Duration",
                    value: viewModel.formatDuration(duration),
                    icon: "clock"
                )
            }
            
            // Sets completed
            let completedSetsCount = session.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
            metricView(
                label: "Sets",
                value: "\(completedSetsCount)",
                icon: "list.bullet"
            )
            
            // Volume (if applicable)
            let volume = viewModel.calculateTotalVolume(session: session)
            if volume > 0 {
                metricView(
                    label: "Volume",
                    value: String(format: "%.0f kg", volume),
                    icon: "scalemass"
                )
            }
            
            // Exercises
            metricView(
                label: "Exercises",
                value: "\(session.exercises.count)",
                icon: "figure.strengthtraining.traditional"
            )
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    
    private func metricView(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    let scheduledWorkout = ScheduledWorkout(
        workoutTemplateId: "test",
        workoutName: "Upper Body Strength",
        dayOfWeek: 2,
        scheduledDate: Date(),
        completedSessionId: "session-123",
        isCompleted: true
    )
    
    WorkoutSummaryCardView(viewModel: WorkoutSummaryCardViewModel(container: DevPreview.shared.container, scheduledWorkout: scheduledWorkout, onTap: {}))
        .previewEnvironment()
}
