//
//  WorkoutSessionActivity.swift
//  WorkoutSessionActivity
//
//  Created by Andrew Coyle on 30/09/2025.
//
//  The Dynamic Island (spec: docs/specs/live-activity.md §5). Every region switches on the
//  same `LiveActivityPhase` the banner uses. The island always renders on black, so it uses
//  semantic colours and never reads the colour scheme.
//

import SwiftUI
import WidgetKit
import ActivityKit
import AppIntents

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
struct WorkoutSessionActivity: Widget {

    /// The widget's accent is `labelColor`; on the island's black background that resolves
    /// light, so a label on a `.borderedProminent` button is drawn dark.
    private static let islandProminentLabelColor = Color.black

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    expandedContent(context: context)
                }
            } compactLeading: {
                compactLeading(context: context)
            } compactTrailing: {
                compactTrailing(context: context)
            } minimal: {
                minimal(context: context)
            }
        }
    }

    private func phase(_ context: ActivityViewContext<WorkoutActivityAttributes>) -> LiveActivityPhase {
        LiveActivityPhase(state: context.state, now: Date(), isStale: context.isStale)
    }

    // MARK: - Expanded

    /// The banner's two rows for the current phase, minus the progress line and minus
    /// `.ended` — the island is dismissed when the workout ends.
    private func expandedContent(context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        LiveActivityPhaseContent(
            phase: phase(context),
            state: context.state,
            workoutName: context.attributes.workoutName,
            prominentLabelColor: Self.islandProminentLabelColor,
            showsEnded: false
        )
        .padding(.horizontal, 4)
    }

    // MARK: - Compact and minimal

    @ViewBuilder
    private func compactLeading(context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        switch phase(context) {
        case let .resting(until, _, _):
            RestRing(until: until, size: 18)
        default:
            ExerciseImage(imageName: context.state.currentExerciseImageName, size: 20)
        }
    }

    @ViewBuilder
    private func compactTrailing(context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        switch phase(context) {
        case let .ready(target, _):
            compactTargetLabel(target)
        case let .restOver(next):
            compactTargetLabel(next)
        case let .resting(until, _, _):
            Text(timerInterval: Date()...until, countsDown: true)
                .monospacedDigit()
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 44)
        case .allSetsDone:
            Text("Done")
                .font(.footnote)
                .foregroundStyle(.green)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func compactTargetLabel(_ target: LiveActivitySetTarget) -> some View {
        if let label = target.label(weightUnit: LiveActivityLayout.weightUnit) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private func minimal(context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        switch phase(context) {
        case let .resting(until, _, _):
            RestRing(until: until, size: 18)
        case .allSetsDone:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        default:
            ExerciseImage(imageName: context.state.currentExerciseImageName, size: 18)
        }
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
