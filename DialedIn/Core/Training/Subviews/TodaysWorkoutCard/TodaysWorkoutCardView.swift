//
//  TodaysWorkoutCardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct TodaysWorkoutCardView: View {
    @State var presenter: TodaysWorkoutCardPresenter

    let delegate: TodaysWorkoutCardDelegate

    var body: some View {
        HStack(spacing: 16) {            
            // Workout info
            VStack(alignment: .leading, spacing: 6) {
                Text(presenter.templateName)
                    .font(.headline)
                
                HStack {
                    Label("\(presenter.exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
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
            .loadingRedaction(isLoading: presenter.isLoading)

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
            await presenter.loadWorkoutDetails(scheduledWorkout: delegate.scheduledWorkout)
        }
    }
}

extension CoreBuilder {
    func todaysWorkoutCardView(router: AnyRouter, delegate: TodaysWorkoutCardDelegate) -> some View {
        TodaysWorkoutCardView(
            presenter: TodaysWorkoutCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

#Preview("Functioning") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        List {
            builder.todaysWorkoutCardView(
                router: router,
                delegate: TodaysWorkoutCardDelegate(
                    scheduledWorkout: ScheduledWorkout.mocksWeek1.first!,
                    onStart: {
                        print("Start workout")
                    }
                )
            )
        }
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        List {
            builder.todaysWorkoutCardView(
                router: router,
                delegate: TodaysWorkoutCardDelegate(
                    scheduledWorkout: ScheduledWorkout.mocksWeek2.first!,
                    onStart: {
                        print("Start workout")
                    }
                )
            )
        }
    }
    .previewEnvironment()
}

#Preview("Failure") {
    let builder = CoreBuilder(container: DevPreview.shared.container())

    RouterView { router in
        List(ScheduledWorkout.mocksWeek3) { workout in
            builder.todaysWorkoutCardView(
                router: router,
                delegate: TodaysWorkoutCardDelegate(
                    scheduledWorkout: workout,
                    onStart: {
                        print("Start workout")
                    }
                )
            )
        }
    }
    .previewEnvironment()
}
