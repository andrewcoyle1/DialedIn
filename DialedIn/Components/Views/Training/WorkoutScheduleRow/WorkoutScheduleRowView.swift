//
//  WorkoutScheduleRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutScheduleRowView: View {

    @State var presenter: WorkoutScheduleRowPresenter

    let delegate: WorkoutScheduleRowDelegate

    var body: some View {
        HStack {
            // Status indicator
            Image(systemName: presenter.statusIcon(workout: delegate.workout))
                .foregroundStyle(presenter.statusColor(workout: delegate.workout))
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(presenter.templateName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let date = delegate.workout.scheduledDate {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if delegate.workout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .task {
            await presenter.loadTemplateName(workout: delegate.workout)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        List {
            Section {
                ForEach(ScheduledWorkout.mocksWeek1) { workout in
                    let delegate = WorkoutScheduleRowDelegate(workout: workout)
                    builder.workoutScheduleRowView(router: router, delegate: delegate)
                }
            } header: {
                Text("This Week's Workouts")
            }
        }
    }
    .previewEnvironment()
}
