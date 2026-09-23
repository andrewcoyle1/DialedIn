//
//  LiveActivityPhaseViews.swift
//  WorkoutSessionActivity
//
//  The two rows each `LiveActivityPhase` renders (spec: docs/specs/live-activity.md §3).
//
//  The lock-screen banner wraps these in a fixed-height container with a progress line;
//  the Dynamic Island's expanded region uses them as-is. Nothing in here reads the colour
//  scheme: the one scheme-dependent value, the label colour on a `.borderedProminent`
//  button, is passed in, because the island always renders on black.
//

import SwiftUI
import WidgetKit
import AppIntents

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)

// MARK: - Shared constants

enum LiveActivityLayout {
    /// One row of the banner. Two of these plus the spacing is the fixed banner height.
    static let rowHeight: CGFloat = 38
    static let rowSpacing: CGFloat = 6
    static let contentHeight: CGFloat = rowHeight * 2 + rowSpacing
    static let imageSize: CGFloat = 38
    static let imageCornerRadius: CGFloat = 6

    /// The content state carries no unit preference, so everything is shown in kilograms.
    /// Follow-up: add a `weightUnit` field to `ContentState` and read it here.
    static let weightUnit: LiveActivityWeightUnit = .kilograms
}

// MARK: - Phase content

/// The two rows for one phase. `.ended` renders its summary here too; the island passes
/// `showsEnded: false` because it is dismissed when the workout ends.
struct LiveActivityPhaseContent: View {

    let phase: LiveActivityPhase
    let state: WorkoutActivityAttributes.ContentState
    let workoutName: String
    /// Foreground for labels sitting on a `.borderedProminent` button.
    let prominentLabelColor: Color
    var showsEnded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: LiveActivityLayout.rowSpacing) {
            switch phase {
            case let .ready(target, position):
                exerciseRow(detail: position.label, dimmed: false)
                targetActionRow(target: target, prefix: nil)

            case let .resting(until, next, logged):
                restingCorrectionRow(logged: logged)
                restingTimerRow(until: until, next: next)

            case let .restOver(next):
                exerciseRow(detail: currentPositionLabel, dimmed: false)
                targetActionRow(target: next, prefix: "Rest over")

            case let .exerciseDone(name, firstTarget):
                doneRow(text: "\(name) done")
                nextExerciseRow(firstTarget: firstTarget)

            case .allSetsDone:
                doneRow(text: "All sets complete")
                finishRow

            case .paused:
                exerciseRow(detail: nil, dimmed: true)
                pausedRow(label: "Paused")

            case .unknown:
                exerciseRow(detail: nil, dimmed: true)
                pausedRow(label: nil)

            case let .ended(summary):
                if showsEnded {
                    doneRow(text: workoutName)
                    summaryRow(summary)
                }
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var currentPositionLabel: String {
        SetPosition(
            index: state.currentExerciseCompletedSetsCount + 1,
            total: state.currentExerciseTotalSetsCount,
            isWarmup: state.targetIsWarmup
        ).label
    }

    // MARK: Row 1 variants

    private func exerciseRow(detail: String?, dimmed: Bool) -> some View {
        HStack(spacing: 10) {
            ExerciseImage(imageName: state.currentExerciseImageName)
            VStack(alignment: .leading, spacing: 0) {
                Text(state.currentExerciseName ?? "")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(dimmed ? Color.secondary : Color.primary)
                if let detail {
                    Text(detail)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .opacity(dimmed ? 0.6 : 1)
        .frame(height: LiveActivityLayout.rowHeight)
    }

    private func doneRow(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)
            Text(text)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .frame(height: LiveActivityLayout.rowHeight)
    }

    /// Row 1 while resting: the correction window. Without a logged set (the rest was
    /// started from the app) it falls back to the exercise and its position.
    @ViewBuilder
    private func restingCorrectionRow(logged: LoggedSet?) -> some View {
        if let logged {
            HStack(spacing: 8) {
                Text("Logged \(logged.label(weightUnit: LiveActivityLayout.weightUnit) ?? "set")")
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Spacer(minLength: 4)
                repsAdjustButton(delta: -1, systemImage: "minus")
                repsAdjustButton(delta: 1, systemImage: "plus")
            }
            .frame(height: LiveActivityLayout.rowHeight)
        } else {
            exerciseRow(detail: currentPositionLabel, dimmed: false)
        }
    }

    private func repsAdjustButton(delta: Int, systemImage: String) -> some View {
        Button(intent: AdjustLastSetRepsIntent(delta: delta)) {
            Image(systemName: systemImage)
                .font(.footnote.weight(.semibold))
                .padding(2)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(.accent)
        .disabled(state.isProcessingIntent)
        .opacity(state.isProcessingIntent ? 0.5 : 1)
    }

    // MARK: Row 2 variants

    private func targetActionRow(target: LiveActivitySetTarget, prefix: String?) -> some View {
        HStack(spacing: 8) {
            if let prefix {
                Text(prefix)
                    .foregroundStyle(.secondary)
            }
            if let label = target.label(weightUnit: LiveActivityLayout.weightUnit) {
                Text(label)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            Button(intent: CompleteSetIntent()) {
                Label("Complete", systemImage: "checkmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(prominentLabelColor)
                    .padding(2)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accent)
            .disabled(state.targetSetId == nil || state.isProcessingIntent)
        }
        .frame(height: LiveActivityLayout.rowHeight)
    }

    private func restingTimerRow(until: Date, next: LiveActivitySetTarget?) -> some View {
        HStack(spacing: 8) {
            RestRing(until: until)
//            Text(timerInterval: Date()...until, countsDown: true)
//                .monospacedDigit()
//                .lineLimit(1)
//                .frame(width: 44)
            if let label = next?.label(weightUnit: LiveActivityLayout.weightUnit) {
                Text("Next \(label)")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 4)
            Button(intent: AdjustRestTimerIntent(adjustment: 15)) {
                Text("+15s")
                    .font(.footnote)
                    .padding(2)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(.accent)
            .disabled(state.isProcessingIntent)
            .opacity(state.isProcessingIntent ? 0.5 : 1)

            Button(intent: SkipRestTimerIntent()) {
                Text("Skip")
                    .font(.footnote)
                    .padding(2)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(.accent)
            .disabled(state.isProcessingIntent)
            .opacity(state.isProcessingIntent ? 0.5 : 1)
        }
        .frame(height: LiveActivityLayout.rowHeight)
    }

    private func nextExerciseRow(firstTarget: LiveActivitySetTarget?) -> some View {
        HStack(spacing: 8) {
            if let next = state.nextExerciseName, !next.isEmpty {
                Text("Next: \(next)")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            if let label = firstTarget?.label(weightUnit: LiveActivityLayout.weightUnit) {
                Text(label)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .frame(height: LiveActivityLayout.rowHeight)
    }

    private var finishRow: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 0)
            Button(intent: CompleteWorkoutIntent()) {
                Label("Finish", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(prominentLabelColor)
                    .padding(2)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accent)
            .disabled(state.isProcessingIntent)
        }
        .frame(height: LiveActivityLayout.rowHeight)
    }

    private func pausedRow(label: String?) -> some View {
        HStack(spacing: 6) {
            if let label {
                Text(label)
                    .foregroundStyle(.primary)
                Text("·")
                    .foregroundStyle(.secondary)
            }
            Text("Resume in the app")
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .frame(height: LiveActivityLayout.rowHeight)
    }

    private func summaryRow(_ summary: Summary) -> some View {
        HStack(spacing: 14) {
            if let duration = summary.durationSeconds {
                summaryMetric(title: "Duration", value: LiveActivitySummaryFormat.duration(duration))
            }
            if let sets = summary.completedSetsCount {
                summaryMetric(title: "Sets", value: "\(sets)")
            }
            if let volume = summary.volumeKg, volume > 0 {
                summaryMetric(title: "Volume", value: LiveActivitySummaryFormat.volume(volume))
            }
            Spacer(minLength: 0)
        }
        .frame(height: LiveActivityLayout.rowHeight)
    }

    private func summaryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Pieces shared with the Dynamic Island

/// The exercise illustration, with the SF Symbol fallback the banner has always used.
struct ExerciseImage: View {

    let imageName: String?
    var size: CGFloat = LiveActivityLayout.imageSize

    var body: some View {
        if let imageName, !imageName.isEmpty {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: LiveActivityLayout.imageCornerRadius))
        } else {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: size * 0.63))
                .foregroundStyle(.secondary)
                .frame(width: size, height: size)
        }
    }
}

/// The circular rest countdown.
struct RestRing: View {

    let until: Date
    var size: CGFloat = 22

    var body: some View {
        ProgressView(timerInterval: Date()...until, countsDown: true)
            .progressViewStyle(.circular)
            .labelsHidden()
            .tint(.accent)
            .frame(width: size, height: size)
    }
}

// MARK: - Summary formatting

/// The end-of-workout figures, formatted as the old summary view formatted them.
enum LiveActivitySummaryFormat {

    static func duration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secs = Int(seconds) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    static func volume(_ kilograms: Double) -> String {
        if kilograms >= 1000 {
            return String(format: "%.1fk kg", kilograms / 1000)
        }
        return String(format: "%.0f kg", kilograms)
    }
}

#endif
