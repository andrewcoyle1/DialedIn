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

struct TrainingView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(DetailNavigationModel.self) private var detail
    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: TrainingViewModel

    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack {
                    contentView
                }
            } else {
                contentView
            }
        }
        // Only show inspector in compact/tabBar modes; not in split view where detail is used
        .modifier(
            InspectorIfCompact(
                isPresented: $viewModel.isShowingInspector,
                inspector: {
                    Group {
                        if let exercise = viewModel.selectedExerciseTemplate {
                            NavigationStack {
                                ExerciseTemplateDetailView(
                                    viewModel: ExerciseTemplateDetailViewModel(container: container),
                                    exerciseTemplate: exercise
                                )
                            }
                        } else if let workout = viewModel.selectedWorkoutTemplate {
                            NavigationStack {
                                WorkoutTemplateDetailView(
                                    viewModel: WorkoutTemplateDetailViewModel(container: container),
                                    workoutTemplate: workout
                                )
                            }
                        } else if let session = viewModel.selectedHistorySession {
                            NavigationStack { WorkoutSessionDetailView(session: session, container: container) }
                        } else {
                            Text("Select an item").foregroundStyle(.secondary).padding()
                        }
                    }
                },
                enabled: layoutMode != .splitView)
        )
        .onChange(of: viewModel.selectedExerciseTemplate) { _, exercise in
            guard layoutMode == .splitView else { return }
            if let exercise { detail.path = [.exerciseTemplate(exerciseTemplate: exercise)] }
        }
        .onChange(of: viewModel.selectedWorkoutTemplate) { _, workout in
            guard layoutMode == .splitView else { return }
            if let workout { detail.path = [.workoutTemplateDetail(template: workout)] }
        }
        .onChange(of: viewModel.selectedHistorySession) { _, session in
            guard layoutMode == .splitView else { return }
            if let session { detail.path = [.workoutSessionDetail(session: session)] }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    private var contentView: some View {
        Group {
            // List {
                // pickerSection
                listContents
            // }
            .scrollIndicators(.hidden)
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView) {
                DevSettingsView(viewModel: DevSettingsViewModel(container: container))
            }
            #endif
            .sheet(isPresented: $viewModel.showNotificationsView) {
                NotificationsView()
            }
            .sheet(item: $viewModel.workoutToStart) { template in
                WorkoutStartView(
                    viewModel: WorkoutStartViewModel(container: container),
                    template: template,
                    scheduledWorkout: viewModel.scheduledWorkoutToStart
                )
            }
            .sheet(item: $viewModel.programActiveSheet) { sheet in
                switch sheet {
                case .programPicker:
                    ProgramManagementView(viewModel: ProgramManagementViewModel(container: container))
                case .progressDashboard:
                    ProgressDashboardView(viewModel: ProgressDashboardViewModel(container: container))
                case .strengthProgress:
                    StrengthProgressView(viewModel: StrengthProgressViewModel(container: container))
                case .workoutHeatmap:
                    WorkoutHeatmapView(viewModel: WorkoutHeatmapViewModel(
                        container: container, progressAnalytics: ProgressAnalyticsService(
                        workoutSessionManager: container.resolve(WorkoutSessionManager.self)!,
                        exerciseTemplateManager: container.resolve(ExerciseTemplateManager.self)!
                    ))
                    )
                }
            }
            .navigationTitle("Training")
            .navigationSubtitle(viewModel.navigationSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $viewModel.showCreateExercise) {
                CreateExerciseView(viewModel: CreateExerciseViewModel(container: container))
            }
            .sheet(isPresented: $viewModel.showCreateWorkout) {
                CreateWorkoutView(viewModel: CreateWorkoutViewModel(container: container))
            }
        }
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
    
    private var listContents: some View {
        Group {
            switch viewModel.presentationMode {
            case .program:
                ProgramView(viewModel: ProgramViewModel(container: container))
            case .workouts:
                WorkoutsView(viewModel: WorkoutsViewModel(
                    container: container,
                    onWorkoutSelectionChanged: { workout in
                        viewModel.selectedWorkoutTemplate = workout
                    }
                ))
            case .exercises:
                ExercisesView(viewModel: ExercisesViewModel(
                    container: container,
                    onExerciseSelectionChanged: { exercise in
                        viewModel.selectedExerciseTemplate = exercise
                    }
                ))
            case .history:
                WorkoutHistoryView(viewModel: WorkoutHistoryViewModel(
                    container: container,
                    onSessionSelectionChanged: { session in
                        viewModel.selectedHistorySession = session
                    }
                ))
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.program
                } label: {
                    Label {
                        Text("Program")
                    } icon: {
                        Image(systemName: viewModel.presentationMode == .program ? "calendar.circle.fill" : "calendar")
                    }
                }
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.workouts
                } label: {
                    Label {
                        Text("Workouts")
                    } icon: {
                        Image(systemName: viewModel.presentationMode == .workouts ? "dumbbell.fill" : "dumbbell")
                    }
                }
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.exercises
                } label: {
                    Label {
                        Text("Exercises")
                    } icon: {
                        Image(systemName: viewModel.presentationMode == .exercises ? "list.bullet.rectangle.portrait.fill" : "list.bullet.rectangle.portrait")
                    }
                }
                Button {
                    viewModel.presentationMode = TrainingPresentationMode.history
                } label: {
                    Label {
                        Text("History")
                    } icon: {
                        Image(systemName: viewModel.presentationMode == .history ? "clock.fill" : "clock")
                    }
                }
            } label: {
                Image(systemName: viewModel.currentMenuIcon)
            }

//            Picker(selection: $presentationMode) {
//                Text("Program")
//                    .tag(TrainingPresentationMode.program)
//                Text("Workouts")
//                    .tag(TrainingPresentationMode.workouts)
//                Text("Exercises")
//                    .tag(TrainingPresentationMode.exercises)
//                Text("History")
//                    .tag(TrainingPresentationMode.history)
//            } label: {
//                Image(systemName: "bell.fill")
//            }
//            .pickerStyle(.menu)
        }
        
        // Today's workout quick action (only if there are incomplete workouts today and not in Program view)
        if viewModel.presentationMode != .program, viewModel.getTodaysWorkouts() {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        do {
                            try await viewModel.startTodaysWorkout()
                        } catch {
                            viewModel.showAlert = AnyAppAlert(error: error)
                        }
                    }
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                }
                .buttonStyle(.glassProminent)
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

#Preview {
    TrainingView(viewModel: TrainingViewModel(container: DevPreview.shared.container))
        .previewEnvironment()
}

enum TrainingPresentationMode {
    case program
    case workouts
    case exercises
    case history
}
