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
    @Environment(\.layoutMode) private var layoutMode

    @State var viewModel: TrainingViewModel
    @Binding var path: [TabBarPathOption]

    var body: some View {
        Group {
            if layoutMode == .tabBar {
                NavigationStack(path: $path) {
                    contentView
                }
                .navDestinationForTabBarModule(path: $path)
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
                                    viewModel: ExerciseTemplateDetailViewModel(interactor: CoreInteractor(container: container)),
                                    exerciseTemplate: exercise
                                )
                            }
                        } else if let workout = viewModel.selectedWorkoutTemplate {
                            NavigationStack {
                                WorkoutTemplateDetailView(
                                    viewModel: WorkoutTemplateDetailViewModel(interactor: CoreInteractor(container: container)),
                                    workoutTemplate: workout
                                )
                            }
                        } else if let session = viewModel.selectedHistorySession {
                            NavigationStack {
                                WorkoutSessionDetailView(
                                    viewModel: WorkoutSessionDetailViewModel(interactor: CoreInteractor(
                                        container: container),
                                        session: session
                                    )
                                )
                            }
                        } else {
                            Text("Select an item").foregroundStyle(.secondary).padding()
                        }
                    }
                },
                enabled: layoutMode != .splitView)
        )
        .onAppear {
            viewModel.presentationMode = .program
        }
        .onChange(of: viewModel.selectedExerciseTemplate) { _, exercise in
            if layoutMode == .splitView {
                if let exercise { path = [.exerciseTemplate(exerciseTemplate: exercise)] }
            } else {
                if exercise != nil { viewModel.isShowingInspector = true }
            }
        }
        .onChange(of: viewModel.selectedWorkoutTemplate) { _, workout in
            if layoutMode == .splitView {
                if let workout { path = [.workoutTemplateDetail(template: workout)] }
            } else {
                if workout != nil { viewModel.isShowingInspector = true }
            }
        }
        .onChange(of: viewModel.selectedHistorySession) { _, session in
            if layoutMode == .splitView {
                if let session { path = [.workoutSessionDetail(session: session)] }
            } else {
                if session != nil { viewModel.isShowingInspector = true }
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    private var contentView: some View {
        Group {
            listContents
            .scrollIndicators(.hidden)
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView) {
                DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
            }
            #endif
            .sheet(isPresented: $viewModel.showNotificationsView) {
                NotificationsView(
                    viewModel: NotificationsViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            .sheet(item: $viewModel.workoutToStart) { template in
                WorkoutStartView(
                    viewModel: WorkoutStartViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    ),
                    template: template,
                    scheduledWorkout: viewModel.scheduledWorkoutToStart
                )
            }
            .sheet(item: $viewModel.programActiveSheet) { sheet in
                switch sheet {
                case .programPicker:
                    ProgramManagementView(
                        viewModel: ProgramManagementViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        )
                    )
                case .progressDashboard:
                    ProgressDashboardView(
                        viewModel: ProgressDashboardViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        )
                    )
                case .strengthProgress:
                    StrengthProgressView(
                        viewModel: StrengthProgressViewModel(
                            interactor: CoreInteractor(
                                container: container
                            )
                        )
                    )
                case .workoutHeatmap:
                    WorkoutHeatmapView(
                        viewModel: WorkoutHeatmapViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            progressAnalytics: ProgressAnalyticsService(
                                workoutSessionManager: container.resolve(
                                    WorkoutSessionManager.self
                                )!,
                                exerciseTemplateManager: container.resolve(
                                    ExerciseTemplateManager.self
                                )!
                            )
                        )
                    )
                case .addGoal:
                    // This case is handled by the ProgramView's sheet modifier
                    EmptyView()
                }
            }
            .navigationTitle("Training")
            .navigationSubtitle(viewModel.navigationSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
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
                ProgramView(
                    viewModel: ProgramViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        onSessionSelectionChanged: { session in
                            viewModel.selectedHistorySession = session
                        },
                        onWorkoutStartRequested: { template, scheduledWorkout in
                            viewModel.handleWorkoutStartRequest(
                                template: template,
                                scheduledWorkout: scheduledWorkout
                            )
                        },
                        onActiveSheetChanged: { sheet in
                            viewModel.programActiveSheet = sheet
                        }
                    )
                )
            case .workouts:
                WorkoutsView(
                    viewModel: WorkoutsViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        onWorkoutSelectionChanged: { workout in
                            viewModel.selectedWorkoutTemplate = workout
                        }
                    )
                )
            case .exercises:
                ExercisesView(
                    viewModel: ExercisesViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        onExerciseSelectionChanged: { exercise in
                            viewModel.selectedExerciseTemplate = exercise
                        }
                    )
                )
            case .history:
                WorkoutHistoryView(
                    viewModel: WorkoutHistoryViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        onSessionSelectionChanged: { session in
                            viewModel.selectedHistorySession = session
                        }
                    )
                )
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
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    TrainingView(
        viewModel: TrainingViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        path: $path
    )
    .previewEnvironment()
}
