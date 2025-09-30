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
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Spacer()
                        Text(timeString(from: context.state.elapsedTime))
                        Text("Sets: \(context.state.completedSetsCount)/\(context.state.totalSetsCount)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        if let exerciseName = context.state.currentExerciseName {
                            Text(exerciseName)
                                .font(.headline)
                        }
                        Text(statusText(from: context))
                            .fixedSize(horizontal: true, vertical: true)
                            .bold()
                            .padding(.vertical)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {

                    Gauge(value: context.state.progress) {
                        Text("Progress")
                    } currentValueLabel: {
                        Text("\(Int(context.state.progress * 100))%")
                    }
                    .gaugeStyle(.accessoryLinear)
                    .padding(.horizontal)
                    .padding(.bottom)
                }

            } compactLeading: {
                Image(systemName: "figure.strengthtraining.traditional")

            } compactTrailing: {
                if let restEndsAt = context.state.restEndsAt, restEndsAt > Date() {
                    Text(restCompact(until: restEndsAt))
                } else {
                    Text(timeCompact(from: context.state.elapsedTime))
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

struct LiveActivityView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text("Workout")
                        .font(.headline)
                    Text(context.attributes.workoutName)
                        .font(.subheadline)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(timeString(from: context.state.elapsedTime))
                    Text("Sets: \(context.state.completedSetsCount)/\(context.state.totalSetsCount)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Gauge(value: context.state.progress) {
                EmptyView()
            } currentValueLabel: {
                Text("\(Int(context.state.progress * 100))%")
            }
            .gaugeStyle(.accessoryLinear)
            .tint(.green)

            Text(statusText(from: context))
                .font(.callout)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.widgetBackground)
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
}
