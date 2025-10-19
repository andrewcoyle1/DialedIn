//
//  DayScheduleSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

// MARK: - Day Schedule Sheet

struct DayScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    
    let date: Date
    let scheduledWorkouts: [ScheduledWorkout]
    
    var body: some View {
        NavigationStack {
            List {
                if scheduledWorkouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Scheduled",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No workouts are scheduled for this day.")
                    )
                } else {
                    Section {
                        ForEach(scheduledWorkouts) { workout in
                            WorkoutScheduleRow(workout: workout)
                        }
                    }
                }
            }
            .navigationTitle(date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DayScheduleSheet(date: Date(), scheduledWorkouts: ScheduledWorkout.mocksWeek1)
        .previewEnvironment()
}

#Preview("No Workouts Scheduled") {
    DayScheduleSheet(date: Date(), scheduledWorkouts: [])
        .previewEnvironment()
}
