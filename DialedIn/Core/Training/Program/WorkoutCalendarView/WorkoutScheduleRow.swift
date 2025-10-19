//
//  WorkoutScheduleRow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct WorkoutScheduleRow: View {
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    let workout: ScheduledWorkout
    @State private var showAlert: AnyAppAlert?
    @State private var templateName: String = "Workout"
    
    var body: some View {
        HStack {
            // Status indicator
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(templateName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let date = workout.scheduledDate {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if workout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .showCustomAlert(alert: $showAlert)
        .task {
            do {
                try await loadTemplateName()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private var statusIcon: String {
        if workout.isCompleted {
            return "checkmark.circle.fill"
        } else if workout.isMissed {
            return "exclamationmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    private var statusColor: Color {
        if workout.isCompleted {
            return .green
        } else if workout.isMissed {
            return .red
        } else {
            return .orange
        }
    }
    
    private func loadTemplateName() async throws {
        templateName = try await workoutTemplateManager.getWorkoutTemplate(id: workout.workoutTemplateId).name
    }
}

#Preview {
    List {
        Section {
            ForEach(ScheduledWorkout.mocksWeek1) { workout in
                WorkoutScheduleRow(workout: workout)
            }
            ForEach(ScheduledWorkout.mocksWeek2) { workout in
                WorkoutScheduleRow(workout: workout)
            }
            ForEach(ScheduledWorkout.mocksWeek2) { workout in
                WorkoutScheduleRow(workout: workout)
            }
        } header: {
            Text("This Week's Workouts")
        }
    }
    .previewEnvironment()
}
