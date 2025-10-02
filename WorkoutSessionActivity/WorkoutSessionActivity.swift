//
//  WorkoutSessionActivity.swift
//  WorkoutSessionActivity
//
//  Created by Andrew Coyle on 30/09/2025.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct WorkoutSessionActivity: Widget {
    var body: some WidgetConfiguration {

        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack {
                        Spacer()
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title2)

                        Text(context.attributes.workoutName)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                    }
                    .frame(minWidth: 85)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Spacer()
                        Text(context.attributes.startedAt, style: .timer)
                            .monospacedDigit()
                            .multilineTextAlignment(.trailing)
                        Text("Exercise: \(context.state.currentExerciseIndex)/\(context.state.totalExercisesCount)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("Set: \(context.state.completedSetsCount)/\(context.state.totalSetsCount)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(minWidth: 85)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        if let exerciseName = context.state.currentExerciseName {
                            Text(exerciseName)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
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
                            Text(statusText(from: context))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                DynamicIslandExpandedRegion(.bottom) {

                    Gauge(value: context.state.progress) {
                        Text("Progress")
                    } currentValueLabel: {
                        Text("\(Int(context.state.progress * 100))%")
                    }
                    .gaugeStyle(.accessoryLinear)
                    .tint(.accent)
                    .padding(.horizontal)
                }

            } compactLeading: {
                Image(systemName: "figure.strengthtraining.traditional")
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
                    Text("Sets: \(context.state.completedSetsCount)/\(context.state.totalSetsCount)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
//                    Text(context.attributes.startedAt, style: .timer)
//                        .frame(minWidth: 65)

                }

            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")

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
            currentExerciseIndex: 1,
            totalExercisesCount: 4,
            restEndsAt: Date().addingTimeInterval(45), // 45 seconds from now
            statusMessage: "Resting",
            totalVolumeKg: 3250,
            progress: 0.42
        )
    }

    static var stale: WorkoutActivityAttributes.ContentState {
        return WorkoutActivityAttributes.ContentState(
            isActive: false,
            completedSetsCount: 5,
            totalSetsCount: 12,
            currentExerciseName: "Bench Press",
            currentExerciseIndex: 1,
            totalExercisesCount: 4,
            restEndsAt: nil,
            statusMessage: "Paused",
            totalVolumeKg: 3250,
            progress: 1 // 0.42
        )
    }

    static var someMetrics: WorkoutActivityAttributes.ContentState {
        return WorkoutActivityAttributes.ContentState(
            isActive: true,
            completedSetsCount: 10,
            totalSetsCount: 12,
            currentExerciseName: "Overhead Tricep Extension (Cable)",
            currentExerciseIndex: 2,
            totalExercisesCount: 4,
            restEndsAt: nil,
            statusMessage: "In progress",
            totalVolumeKg: 4800,
            progress: 0.83
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
