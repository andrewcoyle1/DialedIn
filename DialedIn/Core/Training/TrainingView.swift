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
    @Environment(CoreBuilder.self) private var builder
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
        .inspectorIfCompact(isPresented: $viewModel.isShowingInspector, inspector: {
            Group {
                if let exercise = viewModel.selectedExerciseTemplate {
                    NavigationStack {
                        builder.exerciseTemplateDetailView(exercise: exercise)
                    }
                } else if let workout = viewModel.selectedWorkoutTemplate {
                    NavigationStack {
                        builder.workoutTemplateDetailView(workout: workout)
                    }
                } else if let session = viewModel.selectedHistorySession {
                    NavigationStack {
                        builder.workoutSessionDetailView(session: session)
                    }
                } else {
                    Text("Select an item").foregroundStyle(.secondary).padding()
                }
            }
        }, enabled: layoutMode != .splitView)
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
                builder.devSettingsView()
            }
            #endif
            .sheet(isPresented: $viewModel.showNotificationsView) {
                builder.notificationsView()
            }
            .sheet(item: $viewModel.workoutToStart) { template in
                builder.workoutStartView(template: template, scheduledWorkout: viewModel.scheduledWorkoutToStart)
            }
            .sheet(item: $viewModel.programActiveSheet) { sheet in
                switch sheet {
                case .programPicker:
                    builder.programManagementView(path: $path)
                case .progressDashboard:
                    builder.progressDashboardView()
                case .strengthProgress:
                    builder.strengthProgressView()
                case .workoutHeatmap:
                    builder.workoutHeatmapView()
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
                builder.programView(
                    onSessionSelectionChangeded: { session in
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
            case .workouts:
                builder.workoutsView(onWorkoutSelectionChanged: { workout in
                    viewModel.selectedWorkoutTemplate = workout
                })
            case .exercises:
                builder.exercisesView(onExerciseSelectionChanged: { exercise in
                    viewModel.selectedExerciseTemplate = exercise
                })
            case .history:
                builder.workoutHistoryView(onSessionSelectionChanged: { session in
                    viewModel.selectedHistorySession = session
                })
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.trainingView(path: $path)
        .previewEnvironment()
}
