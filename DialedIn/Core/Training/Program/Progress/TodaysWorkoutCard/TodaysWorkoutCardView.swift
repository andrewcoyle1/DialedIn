//
//  TodaysWorkoutCardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct TodaysWorkoutCardView: View {
    @State var viewModel: TodaysWorkoutCardViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            VStack(spacing: 4) {
                if viewModel.scheduledWorkout.isCompleted {
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
                Text(viewModel.templateName)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Label("\(viewModel.exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let date = viewModel.scheduledWorkout.scheduledDate {
                        Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)
            }
            
            Spacer()
            
            // Start button
            if !viewModel.scheduledWorkout.isCompleted {
                Button {
                    viewModel.onStart()
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
        .task {
            await viewModel.loadWorkoutDetails()
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
}

#Preview {
    List {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(
                container: DevPreview.shared.container,
                scheduledWorkout: ScheduledWorkout.mocksWeek1.first!,
                onStart: { }
            )
        )
    }
    .previewEnvironment()
}
