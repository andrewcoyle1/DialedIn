//
//  WorkoutSummaryCard.swift
//  DialedIn
//
//  Shows a summary of a completed workout session
//

import SwiftUI

struct WorkoutSummaryCard: View {
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    
    let scheduledWorkout: ScheduledWorkout
    let onTap: () -> Void
    
    @State private var session: WorkoutSessionModel?
    @State private var isLoading = true
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        Button {
            onTap()
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
                    Text(session?.name ?? scheduledWorkout.workoutName ?? "Workout")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else if let session = session {
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
            await loadSession()
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    @ViewBuilder
    private func summaryMetrics(for session: WorkoutSessionModel) -> some View {
        HStack(spacing: 16) {
            // Duration
            if let endedAt = session.endedAt {
                let duration = endedAt.timeIntervalSince(session.dateCreated)
                metricView(
                    label: "Duration",
                    value: formatDuration(duration),
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
            let volume = calculateTotalVolume(session: session)
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func calculateTotalVolume(session: WorkoutSessionModel) -> Double {
        session.exercises.flatMap { $0.sets }
            .filter { $0.completedAt != nil }
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    private func loadSession() async {
        guard let sessionId = scheduledWorkout.completedSessionId else {
            isLoading = false
            return
        }
        
        do {
            let fetchedSession = try await workoutSessionManager.getWorkoutSession(id: sessionId)
            await MainActor.run {
                self.session = fetchedSession
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.showAlert = AnyAppAlert(error: error)
            }
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
    
    WorkoutSummaryCard(scheduledWorkout: scheduledWorkout, onTap: {})
        .previewEnvironment()
}
