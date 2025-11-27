//
//  TrainingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import CustomRouting

struct TrainingView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: TrainingPresenter

    @ViewBuilder var programView: (ProgramDelegate) -> AnyView
    @ViewBuilder var workoutsView: (WorkoutsDelegate) -> AnyView
    @ViewBuilder var exercisesView: (ExercisesDelegate) -> AnyView
    @ViewBuilder var workoutHistoryView: (WorkoutHistoryDelegate) -> AnyView

    var body: some View {
        Group {
            switch presenter.presentationMode {
            case .program:
                programView(
                    ProgramDelegate(
                        onSessionSelectionChangeded: { session in
                            presenter.selectedHistorySession = session
                        }
                    )
                )
            case .workouts:
                workoutsView(
                    WorkoutsDelegate(
                        onWorkoutSelectionChanged: { workout in
                            presenter.selectedWorkoutTemplate = workout
                        }
                    )
                )
            case .exercises:
                exercisesView(
                    ExercisesDelegate(
                        onExerciseSelectionChanged: { exercise in
                            presenter.selectedExerciseTemplate = exercise
                        }
                    )
                )
            case .history:
                workoutHistoryView(
                    WorkoutHistoryDelegate(
                        onSessionSelectionChanged: { session in
                            presenter.selectedHistorySession = session
                        }
                    )
                )
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Training")
        .navigationSubtitle(presenter.navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }        .onAppear {
            presenter.presentationMode = .program
        }
    }

    private var pickerSection: some View {
        // Section {
        Picker("Section", selection: $presenter.presentationMode) {
            Text("Program").tag(TrainingPresentationMode.program)
            Text("Workouts").tag(TrainingPresentationMode.workouts)
            Text("Exercises").tag(TrainingPresentationMode.exercises)
            Text("History").tag(TrainingPresentationMode.history)
        }
        .pickerStyle(.segmented)
        .padding(.top, 2)
        // }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
                
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    presenter.presentationMode = TrainingPresentationMode.program
                } label: {
                    Label {
                        Text("Program")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
                
                Button {
                    presenter.presentationMode = TrainingPresentationMode.workouts
                } label: {
                    Label {
                        Text("Workouts")
                    } icon: {
                        Image(systemName: "dumbbell")
                    }
                }
                
                Button {
                    presenter.presentationMode = TrainingPresentationMode.exercises
                } label: {
                    Label {
                        Text("Exercises")
                    } icon: {
                        Image(systemName: "list.bullet.rectangle.portrait")
                    }
                }
                
                Button {
                    presenter.presentationMode = TrainingPresentationMode.history
                } label: {
                    Label {
                        Text("History")
                    } icon: {
                        Image(systemName: "clock")
                    }
                }
            } label: {
                Image(systemName: presenter.currentMenuIcon)
            }
        }
        
        // Today's workout quick action (only if there are incomplete workouts today and not in Program view)
        if presenter.presentationMode != .program, presenter.getTodaysWorkouts() {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.startTodaysWorkout()
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.trainingView(router: router)
    }
    .previewEnvironment()
}
