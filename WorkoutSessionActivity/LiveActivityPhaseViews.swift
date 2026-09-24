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

            case let .resting(until, next, logged, nextExerciseName):
                restingCorrectionRow(logged: logged)
                restingTimerRow(until: until, next: next, nextExerciseName: nextExerciseName)

            case let .restOver(next):
                exerciseRow(detail: currentPositionLabel, dimmed: false)
                targetActionRow(target: next, prefix: "Rest over")

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
                Text("Logged \(logged.label(weightUnit: state.weightUnit) ?? "set")")
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
        .accessibilityLabel(delta > 0 ? "Add a rep" : "Remove a rep")
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
            if let label = target.label(weightUnit: state.weightUnit) {
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

    /// Row 2 while resting. When the rest leads into a different exercise the name goes above
    /// the target, because "Next 40 kg × 10" alone reads as another set of the one just done.
    private func restingTimerRow(until: Date, next: LiveActivitySetTarget?, nextExerciseName: String?) -> some View {
        HStack(spacing: 8) {
            RestRing(until: until)
            let label = next?.label(weightUnit: state.weightUnit)
            if let nextExerciseName {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Next: \(nextExerciseName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    if let label {
                        Text(label)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            } else if let label {
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

/// The rest countdown as a ring with the time left inside it.
///
/// The system circular style draws its own label at a size it picks, which at row height does
/// not fit inside the ring, so the label is hidden and the countdown is drawn as an overlay
/// scaled to the ring. `showsCountdown: false` gives the bare ring for the island's compact
/// slots, where the trailing slot already shows the time.
struct RestRing: View {

    let until: Date
    var size: CGFloat = LiveActivityLayout.rowHeight
    var showsCountdown: Bool = true

    /// The countdown's font as a share of the ring: four monospaced digits and a colon at this
    /// size sit inside the ring with the stroke clear on both sides.
    private static let countdownScale: CGFloat = 0.3
    /// The width the countdown may use inside the ring, inside the stroke.
    private static let countdownWidthScale: CGFloat = 0.72

    var body: some View {
        // The circular timer style draws its own countdown inside the ring and `.labelsHidden()`
        // does not remove it, so the current-value label is given as empty and the time is
        // drawn once, by the overlay.
        ProgressView(timerInterval: Date()...max(until, Date()), countsDown: true) {
            EmptyView()
        } currentValueLabel: {
            EmptyView()
        }
            .progressViewStyle(.circular)
            .tint(.accent)
            .frame(width: size, height: size)
            .overlay {
                if showsCountdown {
                    Text(timerInterval: Date()...max(until, Date()), countsDown: true, showsHours: false)
                        .font(.system(size: size * Self.countdownScale, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .multilineTextAlignment(.center)
                        .frame(width: size * Self.countdownWidthScale)
                }
            }
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
