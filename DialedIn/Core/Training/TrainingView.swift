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

    @Environment(\.layoutMode) private var layoutMode
    @Environment(DetailNavigationModel.self) private var detail
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(AuthManager.self) private var authManager
    @State private var presentationMode: TrainingPresentationMode = .program

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    @State private var showNotificationsView: Bool = false
    
    @State private var searchExerciseTask: Task<Void, Never>?
    @State private var searchWorkoutTask: Task<Void, Never>?
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var showAlert: AnyAppAlert?

    @State private var isShowingInspector: Bool = false
    @State private var selectedExerciseTemplate: ExerciseTemplateModel?
    @State private var selectedWorkoutTemplate: WorkoutTemplateModel?
    @State private var workoutToStart: WorkoutTemplateModel?
    @State private var scheduledWorkoutToStart: ScheduledWorkout?
    @State private var showCreateExercise: Bool = false
    @State private var showCreateWorkout: Bool = false
    // Centralized sheet coordination for ProgramView
    @State private var programActiveSheet: ProgramView.ActiveSheet?
    @State private var selectedHistorySession: WorkoutSessionModel?

    enum TrainingPresentationMode {
        case program
        case workouts
        case exercises
        case history
    }
    
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
        .modifier(InspectorIfCompact(isPresented: $isShowingInspector, inspector: {
            Group {
                if let exercise = selectedExerciseTemplate {
                    NavigationStack { ExerciseDetailView(exerciseTemplate: exercise) }
                } else if let workout = selectedWorkoutTemplate {
                    NavigationStack { WorkoutTemplateDetailView(workoutTemplate: workout) }
                } else if let session = selectedHistorySession {
                    NavigationStack { WorkoutSessionDetailView(session: session) }
                } else {
                    Text("Select an item").foregroundStyle(.secondary).padding()
                }
            }
        }, enabled: layoutMode != .splitView))
        .onChange(of: selectedExerciseTemplate) { _, exercise in
            guard layoutMode == .splitView else { return }
            if let exercise { detail.path = [.exerciseTemplate(exerciseTemplate: exercise)] }
        }
        .onChange(of: selectedWorkoutTemplate) { _, workout in
            guard layoutMode == .splitView else { return }
            if let workout { detail.path = [.workoutTemplateDetail(template: workout)] }
        }
        .onChange(of: selectedHistorySession) { _, session in
            guard layoutMode == .splitView else { return }
            if let session { detail.path = [.workoutSessionDetail(session: session)] }
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    private var contentView: some View {
        Group {
            // List {
                // pickerSection
                listContents
            // }
            .scrollIndicators(.hidden)
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .sheet(isPresented: $showNotificationsView) {
                NotificationsView()
            }
            .sheet(item: $workoutToStart) { template in
                WorkoutStartView(
                    template: template,
                    scheduledWorkout: scheduledWorkoutToStart
                )
            }
            .sheet(item: $programActiveSheet) { sheet in
                switch sheet {
                case .programPicker:
                    ProgramManagementView()
                case .progressDashboard:
                    ProgressDashboardView()
                case .strengthProgress:
                    StrengthProgressView()
                case .workoutHeatmap:
                    WorkoutHeatmapView(
                        progressAnalytics: ProgressAnalyticsService(
                            workoutSessionManager: workoutSessionManager,
                            exerciseTemplateManager: exerciseTemplateManager
                        )
                    )
                }
            }
            .navigationTitle("Training")
            .navigationSubtitle(navigationSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showCreateExercise) {
                CreateExerciseView()
            }
            .sheet(isPresented: $showCreateWorkout) {
                CreateWorkoutView()
            }
        }
    }

    private var pickerSection: some View {
        // Section {
            Picker("Section", selection: $presentationMode) {
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
            switch presentationMode {
            case .program:
                ProgramView(
                    isShowingInspector: $isShowingInspector,
                    selectedWorkoutTemplate: $selectedWorkoutTemplate,
                    selectedExerciseTemplate: $selectedExerciseTemplate,
                    activeSheet: $programActiveSheet,
                    workoutToStart: $workoutToStart,
                    scheduledWorkoutToStart: $scheduledWorkoutToStart
                )
            case .workouts:
                WorkoutsView(isShowingInspector: $isShowingInspector, selectedWorkoutTemplate: $selectedWorkoutTemplate, selectedExerciseTemplate: $selectedExerciseTemplate, showCreateWorkout: $showCreateWorkout)
            case .exercises:
                ExercisesView(isShowingInspector: $isShowingInspector, selectedWorkoutTemplate: $selectedWorkoutTemplate, selectedExerciseTemplate: $selectedExerciseTemplate, showCreateExercise: $showCreateExercise)
            case .history:
                WorkoutHistoryView(alert: $showAlert, selectedSession: $selectedHistorySession, isShowingInspector: $isShowingInspector)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    presentationMode = TrainingPresentationMode.program
                } label: {
                    Label {
                        Text("Program")
                    } icon: {
                        Image(systemName: presentationMode == .program ? "calendar.circle.fill" : "calendar")
                    }
                }
                Button {
                    presentationMode = TrainingPresentationMode.workouts
                } label: {
                    Label {
                        Text("Workouts")
                    } icon: {
                        Image(systemName: presentationMode == .workouts ? "dumbbell.fill" : "dumbbell")
                    }
                }
                Button {
                    presentationMode = TrainingPresentationMode.exercises
                } label: {
                    Label {
                        Text("Exercises")
                    } icon: {
                        Image(systemName: presentationMode == .exercises ? "list.bullet.rectangle.portrait.fill" : "list.bullet.rectangle.portrait")
                    }
                }
                Button {
                    presentationMode = TrainingPresentationMode.history
                } label: {
                    Label {
                        Text("History")
                    } icon: {
                        Image(systemName: presentationMode == .history ? "clock.fill" : "clock")
                    }
                }
            } label: {
                Image(systemName: currentMenuIcon)
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
        if presentationMode != .program, trainingPlanManager.getTodaysWorkouts().contains(where: { !$0.isCompleted }) {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        do {
                            try await startTodaysWorkout()
                        } catch {
                            showAlert = AnyAppAlert(error: error)
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
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
    
    private func onNotificationsPressed() {
        showNotificationsView = true
    }
    
    private var currentMenuIcon: String {
        switch presentationMode {
        case .program:
            return "calendar.circle.fill"
        case .workouts:
            return "dumbbell.fill"
        case .exercises:
            return "list.bullet.rectangle.portrait.fill"
        case .history:
            return "clock.fill"
        }
    }
    
    private var navigationSubtitle: String {
        if presentationMode == .program, let plan = trainingPlanManager.currentTrainingPlan {
            let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                let completedCount = todaysWorkouts.filter { $0.isCompleted }.count
                if completedCount == todaysWorkouts.count {
                    return "\(plan.name) • Today's workout complete ✓"
                } else {
                    return "\(plan.name) • Workout scheduled for today"
                }
            }
            
            let upcomingCount = trainingPlanManager.getUpcomingWorkouts(limit: 1).count
            if upcomingCount > 0 {
                return "\(plan.name) • Next workout scheduled"
            } else {
                return plan.name
            }
        }
        return Date.now.formatted(date: .abbreviated, time: .omitted)
    }
    
    private func startTodaysWorkout() async throws {
        let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
        guard let firstIncomplete = todaysWorkouts.first(where: { !$0.isCompleted }) else { return }
        
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: firstIncomplete.workoutTemplateId)
        
        // Store scheduled workout reference for WorkoutStartView
        scheduledWorkoutToStart = firstIncomplete
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Show WorkoutStartView (preview, notes, etc.)
        workoutToStart = template
    }
}

#Preview {
    TrainingView()
        .previewEnvironment()
}

// Reuse the compact-only inspector modifier from NutritionView
private struct InspectorIfCompact<InspectorContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let inspector: () -> InspectorContent
    let enabled: Bool

    func body(content: Content) -> some View {
        Group {
            if enabled {
                content
                    .inspector(isPresented: $isPresented) { self.inspector() }
            } else {
                content
            }
        }
    }
}
