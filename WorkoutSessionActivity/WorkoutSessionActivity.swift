//
//  WorkoutSessionActivity.swift
//  WorkoutSessionActivity
//
//  Created by Andrew Coyle on 30/09/2025.
//

import SwiftUI
import WidgetKit
import ActivityKit
import AppIntents

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
struct WorkoutSessionActivity: Widget {
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 2) {
                            Image("AppIconInternalDark")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        Text(context.attributes.workoutName)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .font(.caption)
                    }
                    .padding(.leading, 6)
                    .padding(.top, 1)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.startedAt, style: .timer)
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 3)
                        .padding(.top, 1)
                    
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Group {
                        if let currentExerciseName = context.state.currentExerciseName {
                            HStack {
                                if context.state.isAllSetsComplete {
                                    // Show completion icon when all sets are done
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.green)
                                        .frame(width: 40, height: 40)
                                } else if let imageName = context.state.currentExerciseImageName, !imageName.isEmpty {
                                    Image(imageName)
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .opacity((context.state.restEndsAt != nil && context.state.restEndsAt! > Date()) ? 0.7 : 1.0)
                                } else {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 40, height: 40)
                                        .opacity((context.state.restEndsAt != nil && context.state.restEndsAt! > Date()) ? 0.7 : 1.0)
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                    if context.state.isAllSetsComplete {
                                        Text("Workout Complete")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.green)
                                    } else if context.state.restEndsAt != nil && context.state.restEndsAt! > Date() {
                                        Text("Next: \(currentExerciseName)")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.secondary)
                                    } else {
                                        Text(currentExerciseName)
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.primary)
                                    }
                                    if context.state.isAllSetsComplete {
                                        Text("\(context.state.completedSetsCount) sets completed")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.secondary)
                                    } else {
                                        Text("Set \(context.state.currentExerciseCompletedSetsCount + 1) of \(context.state.currentExerciseTotalSetsCount)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.secondary)
                                    }
                                }
                                Spacer()
                            }
                            
                        }
                        HStack {
                            if let restEndsAt = context.state.restEndsAt, restEndsAt > Date(), !context.state.isAllSetsComplete {
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
                            } else {
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
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .frame(height: 40)
                }
            } compactLeading: {
                if let imageName = context.state.currentExerciseImageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading, 2)
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                }
            } compactTrailing: {
                
                if let restEndsAt = context.state.restEndsAt, restEndsAt > Date() {
                    HStack {
                        Text("Rest: ")
                        Text(timerInterval: Date()...restEndsAt)
                            .monospacedDigit()
                            .frame(maxWidth: 40)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                } else {
                    Text("Set \(context.state.currentExerciseCompletedSetsCount + 1)/\(context.state.currentExerciseTotalSetsCount)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } minimal: {
                if let imageName = context.state.currentExerciseImageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                }
            }
        }
    }
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func timeCompact(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        return "\(minutes)m"
    }
    
    private func restRemainingString(until end: Date) -> String {
        let remaining = max(0, Int(ceil(end.timeIntervalSinceNow)))
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func restCompact(until end: Date) -> String {
        let remaining = max(0, Int(ceil(end.timeIntervalSinceNow)))
        let minutes = remaining / 60
        return "R: \(minutes)m"
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
}

extension WorkoutActivityAttributes {
    static var preview: WorkoutActivityAttributes {
        WorkoutActivityAttributes(
            sessionId: UUID().uuidString,
            workoutName: "Chest Workout",
            startedAt: Date(),
            workoutTemplateId: UUID().uuidString
        )
    }
    
    static var previewOld: WorkoutActivityAttributes {
        WorkoutActivityAttributes(
            sessionId: UUID().uuidString,
            workoutName: "Chest Workout",
            startedAt: Date().addingTimeInterval(-3600*1.5),
            workoutTemplateId: UUID().uuidString
        )
    }
}

extension WorkoutActivityAttributes.ContentState {
    static var live: WorkoutActivityAttributes.ContentState {
        return WorkoutActivityAttributes.ContentState(
            isActive: true,
            completedSetsCount: 5,
            totalSetsCount: 12,
            currentExerciseName: "Bench Press",
            currentExerciseImageName: "BarbellBenchPress",
            currentExerciseIndex: 1,
            totalExercisesCount: 4,
            currentExerciseCompletedSetsCount: 2,
            currentExerciseTotalSetsCount: 4,
            targetSetId: UUID().uuidString,
            targetWeightKg: 100.0,
            targetReps: 8,
            targetDistanceMeters: nil,
            targetDurationSec: nil,
            restEndsAt: Date().addingTimeInterval(45), // 45 seconds from now
            statusMessage: "Resting",
            totalVolumeKg: 3250,
            progress: 0.42,
            isWorkoutEnded: false,
            endedSuccessfully: nil,
            finalDurationSeconds: nil,
            finalVolumeKg: nil,
            finalCompletedSetsCount: nil,
            finalTotalExercisesCount: nil,
            isProcessingIntent: false,
            lastIntentTimestamp: nil,
            isAllSetsComplete: false
        )
    }
    
    static var stale: WorkoutActivityAttributes.ContentState {
        return WorkoutActivityAttributes.ContentState(
            isActive: false,
            completedSetsCount: 5,
            totalSetsCount: 12,
            currentExerciseName: "Bench Press",
            currentExerciseImageName: "BarbellBenchPress",
            currentExerciseIndex: 1,
            totalExercisesCount: 4,
            currentExerciseCompletedSetsCount: 2,
            currentExerciseTotalSetsCount: 4,
            targetSetId: UUID().uuidString,
            targetWeightKg: 100.0,
            targetReps: 8,
            targetDistanceMeters: nil,
            targetDurationSec: nil,
            restEndsAt: nil,
            statusMessage: "Paused",
            totalVolumeKg: 3250,
            progress: 1, // 0.42
            isWorkoutEnded: true,
            endedSuccessfully: nil,
            finalDurationSeconds: nil,
            finalVolumeKg: nil,
            finalCompletedSetsCount: nil,
            finalTotalExercisesCount: nil,
            isProcessingIntent: false,
            lastIntentTimestamp: nil,
            isAllSetsComplete: false
        )
    }
    
    static var someMetrics: WorkoutActivityAttributes.ContentState {
        return WorkoutActivityAttributes.ContentState(
            isActive: true,
            completedSetsCount: 10,
            totalSetsCount: 12,
            currentExerciseName: "Overhead Tricep Extension (Cable)",
            currentExerciseImageName: "OverheadExtensionStraightBar",
            currentExerciseIndex: 2,
            totalExercisesCount: 4,
            currentExerciseCompletedSetsCount: 3,
            currentExerciseTotalSetsCount: 3,
            targetSetId: UUID().uuidString,
            targetWeightKg: 60.0,
            targetReps: 12,
            targetDistanceMeters: nil,
            targetDurationSec: nil,
            restEndsAt: nil,
            statusMessage: "In progress",
            totalVolumeKg: 4800,
            progress: 0.83,
            isWorkoutEnded: false,
            endedSuccessfully: nil,
            finalDurationSeconds: nil,
            finalVolumeKg: nil,
            finalCompletedSetsCount: nil,
            finalTotalExercisesCount: nil,
            isProcessingIntent: true,
            lastIntentTimestamp: Date(),
            isAllSetsComplete: true
        )
    }
}

#Preview("Dynamic Island - Expanded", as: .dynamicIsland(.expanded), using: WorkoutActivityAttributes.preview) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}

#Preview("Dynamic Island - Expanded - Old", as: .dynamicIsland(.expanded), using: WorkoutActivityAttributes.previewOld) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}

#Preview("Dynamic Island - Compact", as: .dynamicIsland(.compact), using: WorkoutActivityAttributes.preview) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}

#Preview("Dynamic Island - Compact - Old", as: .dynamicIsland(.compact), using: WorkoutActivityAttributes.previewOld) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}

#Preview("Dynamic Island - Minimal", as: .dynamicIsland(.minimal), using: WorkoutActivityAttributes.preview) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}

#Preview("Dynamic Island - Minimal - Old", as: .dynamicIsland(.minimal), using: WorkoutActivityAttributes.previewOld) {
    WorkoutSessionActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.live
    WorkoutActivityAttributes.ContentState.stale
    WorkoutActivityAttributes.ContentState.someMetrics
}
#endif
