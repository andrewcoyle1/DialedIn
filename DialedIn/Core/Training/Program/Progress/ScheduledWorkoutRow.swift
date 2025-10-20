//
//  ScheduledWorkoutRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct ScheduledWorkoutRow: View {
    let scheduledWorkout: ScheduledWorkout
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(scheduledWorkout.workoutName ?? "Workout") // Would fetch template name
                    .font(.subheadline)
                if let date = scheduledWorkout.scheduledDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if scheduledWorkout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
    
    private var statusIcon: String {
        if scheduledWorkout.isCompleted {
            return "checkmark.circle.fill"
        } else if scheduledWorkout.isMissed {
            return "exclamationmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    private var statusColor: Color {
        if scheduledWorkout.isCompleted {
            return .green
        } else if scheduledWorkout.isMissed {
            return .red
        } else {
            return .gray
        }
    }
}

#Preview {
    List {
    ScheduledWorkoutRow(scheduledWorkout: ScheduledWorkout.mocksWeek1.first!)
    }
}
