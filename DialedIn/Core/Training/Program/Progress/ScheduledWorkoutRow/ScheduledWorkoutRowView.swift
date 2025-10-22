//
//  ScheduledWorkoutRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct ScheduledWorkoutRowView: View {
    @State var viewModel: ScheduledWorkoutRowViewModel
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: viewModel.statusIcon)
                .foregroundStyle(viewModel.statusColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.scheduledWorkout.workoutName ?? "Workout") // Would fetch template name
                    .font(.subheadline)
                if let date = viewModel.scheduledWorkout.scheduledDate {
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
            
            if viewModel.scheduledWorkout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .tappableBackground()
    }
}

#Preview {
    List {
        ScheduledWorkoutRowView(viewModel: ScheduledWorkoutRowViewModel(scheduledWorkout: ScheduledWorkout.mocksWeek1.first!)
        )
    }
}
