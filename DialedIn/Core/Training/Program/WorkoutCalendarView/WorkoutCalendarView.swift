//
//  WorkoutCalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct WorkoutCalendarView: View {

    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: WorkoutCalendarViewModel

    var body: some View {
        Section(isExpanded: $viewModel.isShowingCalendar) {
            builder.enhancedScheduleView(
                getScheduledWorkouts: {
                    viewModel.scheduledWorkouts
                },
                onDateSelected: { date in
                    viewModel.selectedDate = date
                    viewModel.collapsedSubtitle = "Next: \(date.formatted(.dateTime.day().month()))"
                },
                onDateTapped: { date in
                    viewModel.handleDateTapped(
                        date
                    )
                })
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Plan")
                if !viewModel.isShowingCalendar {
                    Text(viewModel.collapsedSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(viewModel.isShowingCalendar ? 0 : 90))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.onCalendarToggled()
            }
            .animation(.easeInOut, value: viewModel.isShowingCalendar)
        }
        .confirmationDialog(
            viewModel.selectedDate?.formatted(date: .long, time: .omitted) ?? "Select Workout",
            isPresented: $viewModel.showWorkoutMenu,
            titleVisibility: .visible
        ) {
            ForEach(viewModel.workoutsForMenu) { workout in
                Button {
                    Task {
                        await viewModel.handleWorkoutSelection(workout)
                    }
                } label: {
                    if let name = workout.workoutName {
                        Text("\(name) \(workout.isCompleted ? "✓" : "")")
                    } else {
                        Text("Workout \(workout.isCompleted ? "✓" : "")")
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .onAppear {
            viewModel.loadScheduledWorkouts()
        }
        .onChange(of: viewModel.trainingPlan) { _, _ in
            viewModel.loadScheduledWorkouts()
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    List {
        builder.workoutCalendarView()
    }
    .previewEnvironment()
}
