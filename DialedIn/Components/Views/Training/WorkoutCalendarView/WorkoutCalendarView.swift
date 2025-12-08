//
//  WorkoutCalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutCalendarView: View {

    @State var presenter: WorkoutCalendarPresenter

    @ViewBuilder var scheduleView: (ScheduleDelegate) -> AnyView

    var body: some View {
        Section(isExpanded: $presenter.isShowingCalendar) {
            scheduleView(
                ScheduleDelegate(
                    getScheduledWorkouts: {
                        presenter.scheduledWorkouts
                    },
                    onDateSelected: { date in
                        presenter.selectedDate = date
                        presenter.collapsedSubtitle = "Next: \(date.formatted(.dateTime.day().month()))"
                    },
                    onDateTapped: { date in
                        presenter.handleDateTapped(
                            date
                        )
                    }
                )
            )
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Plan")
                if !presenter.isShowingCalendar {
                    Text(presenter.collapsedSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(presenter.isShowingCalendar ? 0 : 90))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                presenter.onCalendarToggled()
            }
            .animation(.easeInOut, value: presenter.isShowingCalendar)
        }
        .confirmationDialog(
            presenter.selectedDate?.formatted(date: .long, time: .omitted) ?? "Select Workout",
            isPresented: $presenter.showWorkoutMenu,
            titleVisibility: .visible
        ) {
            ForEach(presenter.workoutsForMenu) { workout in
                Button {
                    Task {
                        await presenter.handleWorkoutSelection(workout)
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
        .onAppear {
            presenter.loadScheduledWorkouts()
        }
        .onChange(of: presenter.trainingPlan) { _, _ in
            presenter.loadScheduledWorkouts()
        }
    }
}

extension CoreBuilder {
    func workoutCalendarView(router: AnyRouter) -> some View {
        WorkoutCalendarView(
            presenter: WorkoutCalendarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            scheduleView: { delegate in
                self.scheduleView(delegate: delegate)
                    .any()
            }
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        List {
            builder.workoutCalendarView(
                router: router
            )
        }
    }
    .previewEnvironment()
}
