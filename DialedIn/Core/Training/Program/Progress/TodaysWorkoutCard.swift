//
//  TodaysWorkoutCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct TodaysWorkoutCard: View {
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    let scheduledWorkout: ScheduledWorkout
    let onStart: () -> Void
    
    @State private var templateName: String = "Workout"
    @State private var exerciseCount: Int = 0
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            VStack(spacing: 4) {
                if scheduledWorkout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    Text("Ready")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }
            
            // Workout info
            VStack(alignment: .leading, spacing: 6) {
                Text(templateName)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Label("\(exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let date = scheduledWorkout.scheduledDate {
                        Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)
            }
            
            Spacer()
            
            // Start button
            if !scheduledWorkout.isCompleted {
                Button {
                    onStart()
                } label: {
                    Text("Start")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .task {
            do {
                try await loadWorkoutDetails()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    private func loadWorkoutDetails() async throws {
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
            templateName = template.name
            exerciseCount = template.exercises.count
        
    }
}

#Preview {
    TodaysWorkoutCard(
        scheduledWorkout: ScheduledWorkout.mocksWeek1.first!,
        onStart: {
            
        }
    )
    .previewEnvironment()
}
