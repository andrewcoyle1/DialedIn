//
//  ThisWeeksWorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI
import CustomRouting

struct ThisWeeksWorkoutsView<WorkoutSummaryCardView: View, ScheduledWorkoutRowView: View>: View {
    
    @State var presenter: ThisWeeksWorkoutsPresenter
    
    @ViewBuilder var workoutSummaryCardView: (WorkoutSummaryCardDelegate) -> WorkoutSummaryCardView
    @ViewBuilder var scheduledWorkoutRowView: (ScheduledWorkoutRowDelegate) -> ScheduledWorkoutRowView
    
    var body: some View {
        Section(isExpanded: $presenter.isExpanded) {
            let calendar = Calendar.current
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    dayWorkoutRow(dayOffset: dayOffset, weekStart: weekInterval.start, calendar: calendar)
                }
            }
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("This Week's Workouts")
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(presenter.isExpanded ? 0 : 90))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                presenter.onSectionToggled()
            }
            .animation(.easeInOut, value: presenter.isExpanded)
        }
    }
    
    @ViewBuilder
    private func dayWorkoutRow(dayOffset: Int, weekStart: Date, calendar: Calendar) -> some View {
        let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
        let workoutsForDay = presenter.getWorkoutsForDay(day, calendar: calendar)
        
        if workoutsForDay.isEmpty {
            RestDayRow(date: day)
        } else {
            ForEach(workoutsForDay) { workout in
                if workout.isCompleted {
                    workoutSummaryCardView(
                        WorkoutSummaryCardDelegate(
                            scheduledWorkout: workout, onTap: {
                                presenter.openCompletedSession(for: workout)
                            }
                        )
                    )
                    .id(workout.id)
                } else {
                    scheduledWorkoutRowView(ScheduledWorkoutRowDelegate(scheduledWorkout: workout))
                    .contentShape(
                        Rectangle()
                    )
                    .onTapGesture {
                        Task {
                            await presenter.startWorkout(
                                workout
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.thisWeeksWorkoutsView(router: router)
    }
}
