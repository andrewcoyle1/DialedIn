//
//  ProgramScheduleView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct ProgramScheduleViewDelegate {
    let plan: TrainingPlan
}

struct ProgramScheduleView: View {
    @State var viewModel: ProgramScheduleViewModel

    let delegate: ProgramScheduleViewDelegate

    var body: some View {
        List(viewModel.weeks(for: delegate.plan)) { week in
            weekSection(week)
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func weekSection(_ week: TrainingWeek) -> some View {
        Section {
            ForEach(week.scheduledWorkouts) { workout in
                workoutRow(workout)
            }
        } header: {
            HStack {
                Text("Week \(week.weekNumber)")
                Spacer()
                let completed = week.scheduledWorkouts.filter { $0.isCompleted }.count
                Text("\(completed)/\(week.scheduledWorkouts.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    func workoutRow(_ workout: ScheduledWorkout) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Workout")
                    .font(.subheadline)
                if let date = workout.scheduledDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if workout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if workout.isMissed {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.programScheduleView(router: router, delegate: ProgramScheduleViewDelegate(plan: .mock))
    }
}
