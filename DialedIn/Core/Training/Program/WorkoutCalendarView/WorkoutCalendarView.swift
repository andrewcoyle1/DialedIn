//
//  WorkoutCalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct WorkoutCalendarViewDelegate {
    let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
    let onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)?
}

struct WorkoutCalendarView: View {

    @State var viewModel: WorkoutCalendarViewModel

    let delegate: WorkoutCalendarViewDelegate

    @ViewBuilder var enhancedScheduleView: (EnhancedScheduleViewDelegate) -> AnyView

    var body: some View {
        Section(isExpanded: $viewModel.isShowingCalendar) {
            enhancedScheduleView(
                EnhancedScheduleViewDelegate(
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
                    }
                )
            )
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
        builder.workoutCalendarView(delegate: WorkoutCalendarViewDelegate(onSessionSelectionChanged: nil, onWorkoutStartRequested: nil))
    }
    .previewEnvironment()
}
