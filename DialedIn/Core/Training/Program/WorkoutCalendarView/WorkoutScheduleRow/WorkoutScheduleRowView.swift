//
//  WorkoutScheduleRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct WorkoutScheduleRowView: View {
    @State var viewModel: WorkoutScheduleRowViewModel
        
    var body: some View {
        HStack {
            // Status indicator
            Image(systemName: viewModel.statusIcon)
                .foregroundStyle(viewModel.statusColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.templateName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let date = viewModel.workout.scheduledDate {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if viewModel.workout.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .task {
            do {
                try await viewModel.loadTemplateName()
            } catch {
                viewModel.showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

#Preview {
    List {
        Section {
            ForEach(ScheduledWorkout.mocksWeek1) { workout in
                WorkoutScheduleRowView(
                    viewModel: WorkoutScheduleRowViewModel(
                        interactor: CoreInteractor(
                            container: DevPreview.shared.container
                        ),
                        workout: workout
                    )
                )
            }
            ForEach(ScheduledWorkout.mocksWeek2) { workout in
                WorkoutScheduleRowView(
                    viewModel: WorkoutScheduleRowViewModel(
                        interactor: CoreInteractor(
                            container: DevPreview.shared.container
                        ),
                        workout: workout
                    )
                )
            }
            ForEach(ScheduledWorkout.mocksWeek2) { workout in
                WorkoutScheduleRowView(
                    viewModel: WorkoutScheduleRowViewModel(
                        interactor: CoreInteractor(
                            container: DevPreview.shared.container
                        ),
                        workout: workout
                    )
                )
            }
        } header: {
            Text("This Week's Workouts")
        }
    }
    .previewEnvironment()
}
