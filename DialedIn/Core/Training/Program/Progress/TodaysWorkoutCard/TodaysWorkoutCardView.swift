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
            // Workout info
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.templateName)
                    .font(.headline)
                
                HStack {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .loadingRedaction(isLoading: viewModel.isLoading)

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

#Preview("Functioning") {
    List {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container),
                scheduledWorkout: ScheduledWorkout.mocksWeek1.first!,
                onStart: {
                    print("Start workout")
                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    List {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container),
                scheduledWorkout: ScheduledWorkout.mocksWeek2.first!,
                onStart: {
                    print("Start workout")
                }
            )
        )
    }
    .previewEnvironment()
}

#Preview("Failure") {
    List {
        TodaysWorkoutCardView(
            viewModel: TodaysWorkoutCardViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container),
                scheduledWorkout: ScheduledWorkout.mocksWeek3.first!,
                onStart: {
                    print("Start workout")
                }
            )
        )
    }
    .previewEnvironment()
}
