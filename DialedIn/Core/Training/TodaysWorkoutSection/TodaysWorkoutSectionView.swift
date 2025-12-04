//
//  TodaysWorkoutSectionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

import SwiftUI
import SwiftfulRouting

struct TodaysWorkoutSectionView<WorkoutSummary: View, TodaysWorkout: View>: View {
    
    @State var presenter: TodaysWorkoutSectionPresenter
    
    @ViewBuilder var workoutSummaryCardView: (WorkoutSummaryCardDelegate) -> WorkoutSummary
    @ViewBuilder var todaysWorkoutCardView: (TodaysWorkoutCardDelegate) -> TodaysWorkout

    var body: some View {
        Group {
            let todaysWorkouts = presenter.todaysWorkouts
            if !todaysWorkouts.isEmpty {
                Section {
                    ForEach(todaysWorkouts) { workout in
                        if workout.isCompleted {
                            workoutSummaryCardView(
                                WorkoutSummaryCardDelegate(
                                    scheduledWorkout: workout,
                                    onTap: {
                                        presenter.openCompletedSession(
                                            for: workout
                                        )
                                    }
                                )
                            )
                            .id(workout.id)
                        } else {
                            todaysWorkoutCardView(
                                TodaysWorkoutCardDelegate(
                                    scheduledWorkout: workout,
                                    onStart: {
                                        Task {
                                            await presenter.startWorkout(workout)
                                        }
                                    }
                                )
                            )
                        }
                    }
                } header: {
                    Text("Today's Workout")
                }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    
    RouterView { router in
        builder.todaysWorkoutSectionView(router: router)
    }
}
