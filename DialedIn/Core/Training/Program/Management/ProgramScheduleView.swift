//
//  ProgramScheduleView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct ProgramScheduleView: View {
    let plan: TrainingPlan
    
    var body: some View {
        List {
            ForEach(plan.weeks.sorted(by: { $0.weekNumber < $1.weekNumber })) { week in
                Section {
                    ForEach(week.scheduledWorkouts) { workout in
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
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProgramScheduleView(plan: TrainingPlan.mock)
        .previewEnvironment()
}
