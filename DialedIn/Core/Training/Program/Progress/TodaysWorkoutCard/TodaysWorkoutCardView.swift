//
//  TodaysWorkoutCardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct TodaysWorkoutCardViewDelegate {
    let scheduledWorkout: ScheduledWorkout
    let onStart: () -> Void
}

struct TodaysWorkoutCardView: View {
    @State var viewModel: TodaysWorkoutCardViewModel

    let delegate: TodaysWorkoutCardViewDelegate

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
                    
                    if let date = delegate.scheduledWorkout.scheduledDate {
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
            if !delegate.scheduledWorkout.isCompleted {
                Button {
                    delegate.onStart()
                } label: {
                    Text("Start")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .task {
            await viewModel.loadWorkoutDetails(scheduledWorkout: delegate.scheduledWorkout)
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
}

#Preview("Functioning") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    List {
        builder.todaysWorkoutCardView(
            delegate: TodaysWorkoutCardViewDelegate(
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    List {
        builder.todaysWorkoutCardView(
            delegate: TodaysWorkoutCardViewDelegate(
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
    let builder = CoreBuilder(container: DevPreview.shared.container)

    List(ScheduledWorkout.mocksWeek3) { workout in
        builder.todaysWorkoutCardView(
            delegate: TodaysWorkoutCardViewDelegate(
                scheduledWorkout: workout,
                onStart: {
                    print("Start workout")
                }
            )
        )
    }
    .previewEnvironment()
}
