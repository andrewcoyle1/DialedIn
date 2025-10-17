//
//  LiveActivityView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/10/2025.
//

import SwiftUI
import WidgetKit
import AppIntents

struct LiveActivityView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image("AppIconInternalDark")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 20, height: 20)
                HStack(alignment: .firstTextBaseline) {
                    
                    Text(context.attributes.workoutName)
                        .foregroundStyle(.secondary)
                    Spacer()
                    
                    Text(context.attributes.startedAt, style: .timer)
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                }
                .font(.callout)
                
            }
            if let currentExerciseName = context.state.currentExerciseName {
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
                            .foregroundStyle(Color.primary)
                        Text("Set \(context.state.completedSetsCount) of \(context.state.totalSetsCount)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                }
                
            }
            HStack {
                if let restEndsAt = context.state.restEndsAt, restEndsAt > Date() {
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
                            Button(intent: SkipRestTimerIntent()) {
                                Text("Skip")
                                    .foregroundStyle(Color.white)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    HStack {
                        Text("Target: 100 kg x 8 reps")
                            .font(.headline)
                        Spacer()
                        Button(intent: CompleteSetIntent()) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(height: 55)
            
        }
        .padding()
        .background(Color.black)
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

//            HStack {
//                VStack(alignment: .leading, spacing: 0) {
//
//                    Image(systemName: "figure.strengthtraining.traditional")
//                        .font(.title2)
//
//                    Text(context.attributes.workoutName)
//                        .multilineTextAlignment(.leading)
//                        .font(.headline)
//                        .lineLimit(2)
//                        .frame(height: 50)
//                }
//                .frame(maxWidth: 70)
//
//                Spacer()
//
//                VStack {
//                    if let exerciseName = context.state.currentExerciseName {
//                        Text(exerciseName)
//                            .font(.headline)
//                            .multilineTextAlignment(.center)
//                            .lineLimit(2)
//                    }
//                    if let restEndsAt = context.state.restEndsAt, restEndsAt > Date() {
//                        HStack {
//                            Text("Rest: ")
//                            Text(timerInterval: Date()...restEndsAt)
//                                .monospacedDigit()
//                                .frame(maxWidth: 40)
//                        }
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    } else {
//                        Text(statusText(from: context))
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                }
//
//                Spacer()
//
//                VStack(alignment: .trailing) {
//                    Spacer()
//                    Text(context.attributes.startedAt, style: .timer)
//                        .monospacedDigit()
//                        .multilineTextAlignment(.trailing)
//                    Text("Exercise: \(context.state.currentExerciseIndex)/\(context.state.totalExercisesCount)")
//                        .font(.footnote)
//                        .foregroundColor(.secondary)
//                    Text("Sets: \(context.state.completedSetsCount)/\(context.state.totalSetsCount)")
//                        .font(.footnote)
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: 70)
//            }
//            .frame(maxWidth: .infinity)
//
//            Gauge(value: context.state.progress) {
//                EmptyView()
//            } currentValueLabel: {
//                Text("\(Int(context.state.progress * 100))%")
//            }
//            .gaugeStyle(.accessoryLinear)
//            .tint(.accent)
//
