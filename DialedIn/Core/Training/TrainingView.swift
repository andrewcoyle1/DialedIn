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

    @State var viewModel: TrainingViewModel

    @ViewBuilder var programView: (ProgramViewDelegate) -> AnyView
    @ViewBuilder var workoutsView: (WorkoutsViewDelegate) -> AnyView
    @ViewBuilder var exercisesView: (ExercisesViewDelegate) -> AnyView
    @ViewBuilder var workoutHistoryView: (WorkoutHistoryViewDelegate) -> AnyView

    var body: some View {
        Group {
            switch viewModel.presentationMode {
            case .program:
                programView(
                    ProgramViewDelegate(
                        onSessionSelectionChangeded: { session in
                            viewModel.selectedHistorySession = session
                        }
                    )
                )
            case .workouts:
                workoutsView(
                    WorkoutsViewDelegate(
                        onWorkoutSelectionChanged: { workout in
                            viewModel.selectedWorkoutTemplate = workout
                        }
                    )
                )
            case .exercises:
                exercisesView(
                    ExercisesViewDelegate(
                        onExerciseSelectionChanged: { exercise in
                            viewModel.selectedExerciseTemplate = exercise
                        }
                    )
                )
            case .history:
                workoutHistoryView(
                    WorkoutHistoryViewDelegate(
                        onSessionSelectionChanged: { session in
                            viewModel.selectedHistorySession = session
                        }
                    )
                )
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Training")
        .navigationSubtitle(viewModel.navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }        .onAppear {
            viewModel.presentationMode = .program
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }

    private var pickerSection: some View {
        // Section {
        Picker("Section", selection: $viewModel.presentationMode) {
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
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
                
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.program
                } label: {
                    Label {
                        Text("Program")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
                
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.workouts
                } label: {
                    Label {
                        Text("Workouts")
                    } icon: {
                        Image(systemName: "dumbbell")
                    }
                }
                
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.exercises
                } label: {
                    Label {
                        Text("Exercises")
                    } icon: {
                        Image(systemName: "list.bullet.rectangle.portrait")
                    }
                }
                
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.history
                } label: {
                    Label {
                        Text("History")
                    } icon: {
                        Image(systemName: "clock")
                    }
                }
            } label: {
                Image(systemName: viewModel.currentMenuIcon)
            }
        }
        
        // Today's workout quick action (only if there are incomplete workouts today and not in Program view)
        if viewModel.presentationMode != .program, viewModel.getTodaysWorkouts() {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.startTodaysWorkout()
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
