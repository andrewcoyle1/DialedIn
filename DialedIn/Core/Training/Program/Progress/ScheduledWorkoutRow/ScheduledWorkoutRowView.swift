//
//  ScheduledWorkoutRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct ScheduledWorkoutRowViewDelegate {
    let scheduledWorkout: ScheduledWorkout
}

struct ScheduledWorkoutRowView: View {

    @State var viewModel: ScheduledWorkoutRowViewModel

    let delegate: ScheduledWorkoutRowViewDelegate

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: viewModel.statusIcon(scheduledWorkout: delegate.scheduledWorkout))
                .foregroundStyle(viewModel.statusColor(scheduledWorkout: delegate.scheduledWorkout))

            VStack(alignment: .leading, spacing: 2) {
                Text(delegate.scheduledWorkout.workoutName ?? "Workout") // Would fetch template name
                    .font(.subheadline)
                if let date = delegate.scheduledWorkout.scheduledDate {
                    MetricView(
                        label: "Date",
                        value: date.formatted(.dateTime.day().month()),
                        icon: "calendar"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if delegate.scheduledWorkout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .tappableBackground()
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    List {
        builder.scheduledWorkoutRowView(delegate: ScheduledWorkoutRowViewDelegate(scheduledWorkout: ScheduledWorkout.mocksWeek1.first!))
    }
}
