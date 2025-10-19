//
//  LiveActivityView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/10/2025.
//

import SwiftUI
import WidgetKit
import AppIntents

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
struct LiveActivityView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        Group {
            if context.state.isWorkoutEnded && context.state.endedSuccessfully == true {
                workoutSummaryView
            } else {
                activeWorkoutView
            }
        }
        .padding()
        .background(Color.black)
    }
    
    private var workoutSummaryView: some View {
        VStack(spacing: 12) {
            // Header with icon and workout name
            workoutSummaryHeader
            // Summary metrics grid
            summaryMetricsGrid
            Text("Workout Complete!")
                .font(.subheadline)
                .foregroundStyle(.green)
        }
    }
    
    private var workoutSummaryHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
            
            Text(context.attributes.workoutName)
                .font(.headline)
                .foregroundStyle(Color.white)
            
            Spacer()
        }
    }
    
    private var summaryMetricsGrid: some View {
        HStack(spacing: 16) {
            // Duration
            VStack(alignment: .leading, spacing: 2) {
                Text("Duration")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let duration = context.state.finalDurationSeconds {
                    Text(formatDuration(duration))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
            }
            
            Spacer()
            
            // Sets
            VStack(alignment: .leading, spacing: 2) {
                Text("Sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let sets = context.state.finalCompletedSetsCount {
                    Text("\(sets)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            // Volume
            if let volume = context.state.finalVolumeKg, volume > 0 {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatVolume(volume))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            // Exercises
            VStack(alignment: .leading, spacing: 2) {
                Text("Exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let exercises = context.state.finalTotalExercisesCount {
                    Text("\(exercises)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        
    }
    
    private var activeWorkoutView: some View {
        VStack {
            headerSection
            if let currentExerciseName = context.state.currentExerciseName {
                // Show "Next:" during rest, but not if all sets are complete
                if let restEndsAt = context.state.restEndsAt, restEndsAt > Date(), !context.state.isAllSetsComplete {
                    // Show "Next:" during rest
                    nextExerciseSection(currentExerciseName: currentExerciseName)
                } else if !context.state.isAllSetsComplete {
                    // Show current exercise normally when not resting and sets remain
                    currentExerciseSection(currentExerciseName: currentExerciseName)
                } else {
                    // All sets complete - show completion message
                    completedExerciseSection(currentExerciseName: currentExerciseName)
                }
            }
            HStack {
                if let restEndsAt = context.state.restEndsAt, restEndsAt > Date(), !context.state.isAllSetsComplete {
                    restingContent(restEndsAt: restEndsAt)
                } else {
                    completeSetContent
                }
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .frame(height: 55)
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            Image("AppIconInternalDark")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 20, height: 20)
            HStack(alignment: .firstTextBaseline) {
                
                Text(context.attributes.workoutName)
                    
                Spacer()
                
                Text(context.attributes.startedAt, style: .timer)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
            }
            .font(.callout)
            .foregroundStyle(.white)
        }
    }
    
    private func currentExerciseSection(currentExerciseName: String) -> some View {
        HStack {
            // Display exercise image if available
            if let imageName = context.state.currentExerciseImageName, !imageName.isEmpty {
                Image(imageName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 38, height: 38)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
                    .frame(width: 38, height: 38)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(currentExerciseName)
                    .font(.headline)
                    .fontWeight(.medium)
                Text("Set \(context.state.currentExerciseCompletedSetsCount + 1) of \(context.state.currentExerciseTotalSetsCount)")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            Spacer()
        }
    }
    
    private func nextExerciseSection(currentExerciseName: String) -> some View {
        HStack {
            // Display exercise image if available
            if let imageName = context.state.currentExerciseImageName, !imageName.isEmpty {
                Image(imageName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 38, height: 38)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .opacity(0.7)
            } else {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
                    .frame(width: 38, height: 38)
                    .opacity(0.7)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Next: \(currentExerciseName)")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text("Set \(context.state.currentExerciseCompletedSetsCount + 1) of \(context.state.currentExerciseTotalSetsCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
    
    private func completedExerciseSection(currentExerciseName: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.green)
                .frame(width: 38, height: 38)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Workout Complete")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
                Text("\(context.state.completedSetsCount) sets completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
    
    private func restingContent(restEndsAt: Date) -> some View {
        VStack {
            ProgressView(timerInterval: Date()...restEndsAt)
                .labelsHidden()
            HStack {
                Button(intent: AdjustRestTimerIntent(adjustment: -15)) {
                    Text("-15s")
                        .padding(8)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
                .disabled(context.state.isProcessingIntent)
                .opacity(context.state.isProcessingIntent ? 0.5 : 1.0)
                Spacer()
                Text("Rest: ")
                Text(timerInterval: Date()...restEndsAt)
                    .monospacedDigit()
                    .frame(maxWidth: 40)
                Spacer()
                Button(intent: AdjustRestTimerIntent(adjustment: 15)) {
                    Text("+15s")
                        .padding(8)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
                .disabled(context.state.isProcessingIntent)
                .opacity(context.state.isProcessingIntent ? 0.5 : 1.0)
                
                Button(intent: SkipRestTimerIntent()) {
                    if context.state.isProcessingIntent {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Skip")
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(context.state.isProcessingIntent)
            }
        }
    }
    
    private var completeSetContent: some View {
        HStack {
            if context.state.isAllSetsComplete {
                // Show "Complete Workout" when all sets are done
                Text("All sets complete!")
                    .font(.headline)
                    .foregroundStyle(.green)
                Spacer()
                Button(intent: CompleteWorkoutIntent()) {
                    if context.state.isProcessingIntent {
                        ProgressView()
                            .tint(.white)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Finish")
                        }
                        .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(context.state.isProcessingIntent)
            } else {
                // Show target and complete set button
                if let weight = context.state.targetWeightKg, let reps = context.state.targetReps {
                    Text("Target: \(String(format: "%.1f", weight)) kg × \(reps) reps")
                        .font(.headline)
                } else if let reps = context.state.targetReps {
                    Text("Target: \(reps) reps")
                        .font(.headline)
                } else if let distance = context.state.targetDistanceMeters, let duration = context.state.targetDurationSec {
                    let minutes = duration / 60
                    let seconds = duration % 60
                    Text("Target: \(String(format: "%.0f", distance))m in \(minutes):\(String(format: "%02d", seconds))")
                        .font(.headline)
                } else if let duration = context.state.targetDurationSec {
                    let minutes = duration / 60
                    let seconds = duration % 60
                    Text("Target: \(minutes):\(String(format: "%02d", seconds))")
                        .font(.headline)
                } else {
                    Text("Complete Set")
                        .font(.headline)
                }
                Spacer()
                Button(intent: CompleteSetIntent()) {
                    if context.state.isProcessingIntent {
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.secondary)
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(context.state.targetSetId == nil || context.state.isProcessingIntent)
            }
        }
    }
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func restRemainingString(until end: Date) -> String {
        let remaining = max(0, Int(ceil(end.timeIntervalSinceNow)))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func statusText(from context: ActivityViewContext<WorkoutActivityAttributes>) -> String {
        if let restEndsAt = context.state.restEndsAt, restEndsAt > Date() {
            return "Rest: \(restRemainingString(until: restEndsAt))"
        }
        if let status = context.state.statusMessage, !status.isEmpty {
            return status
        }
        return context.state.isActive ? "In progress" : "Paused"
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func formatVolume(_ kilograms: Double) -> String {
        if kilograms >= 1000 {
            return String(format: "%.1fk kg", kilograms / 1000)
        } else {
            return String(format: "%.0f kg", kilograms)
        }
    }
}

#Preview("Notification", as: .content, using: WorkoutActivityAttributes.preview) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}

#Preview("Notification - Old", as: .content, using: WorkoutActivityAttributes.previewOld) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}
#endif
